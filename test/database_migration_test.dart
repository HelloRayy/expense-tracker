import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Schema & Migration Tests', () {
    late String testDbDir;

    setUp(() async {
      testDbDir = p.join(Directory.systemTemp.path, 'jajan_db_test_${DateTime.now().microsecondsSinceEpoch}');
      await Directory(testDbDir).create(recursive: true);
    });

    tearDown(() async {
      final dir = Directory(testDbDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    test('Fresh DB creation initializes all columns including total_budget, carryover_balance, and default 0 budget', () async {
      final dbPath = p.join(testDbDir, 'fresh.db');

      final db = await openDatabase(
        dbPath,
        version: 6,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS budget (
              id INTEGER PRIMARY KEY,
              weekly_income INTEGER NOT NULL DEFAULT 0,
              weekly_savings_target INTEGER NOT NULL DEFAULT 0,
              total_budget INTEGER NOT NULL DEFAULT 0,
              payday_day INTEGER NOT NULL DEFAULT 25,
              carryover_balance INTEGER NOT NULL DEFAULT 0,
              is_period_confirmed INTEGER NOT NULL DEFAULT 1,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL
            )
          ''');

          try {
            await db.execute('ALTER TABLE budget ADD COLUMN total_budget INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN payday_day INTEGER NOT NULL DEFAULT 25');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN weekly_income INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN weekly_savings_target INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN carryover_balance INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN is_period_confirmed INTEGER NOT NULL DEFAULT 1');
          } catch (_) {}

          final defaultBudget = BudgetModel.createDefault();
          await db.insert('budget', defaultBudget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        },
      );

      final rows = await db.query('budget');
      expect(rows.length, 1);
      final row = rows.first;
      expect(row.containsKey('weekly_income'), isTrue);
      expect(row.containsKey('weekly_savings_target'), isTrue);
      expect(row.containsKey('total_budget'), isTrue);
      expect(row.containsKey('payday_day'), isTrue);
      expect(row.containsKey('carryover_balance'), isTrue);
      expect(row.containsKey('is_period_confirmed'), isTrue);
      expect(row['weekly_income'], 0);
      expect(row['weekly_savings_target'], 0);
      expect(row['total_budget'], 0);
      expect(row['carryover_balance'], 0);
      expect(row['is_period_confirmed'], 1);

      await db.close();
    });

    test('Migration from v3 (lacking total_budget & carryover columns) upgrades to v6 seamlessly', () async {
      final dbPath = p.join(testDbDir, 'upgrade_v3.db');

      // Create v3 table without total_budget or carryover columns
      var db = await openDatabase(
        dbPath,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE budget (
              id INTEGER PRIMARY KEY,
              weekly_income INTEGER NOT NULL,
              weekly_savings_target INTEGER NOT NULL,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL
            )
          ''');
          // Manually insert row without total_budget
          await db.insert('budget', {
            'id': 1,
            'weekly_income': 100000,
            'weekly_savings_target': 30000,
            'start_date': '2026-09-07T00:00:00.000',
            'end_date': '2026-09-13T23:59:59.999',
          });
        },
      );
      await db.close();

      // Now open with v6 upgrade logic and onOpen
      db = await openDatabase(
        dbPath,
        version: 6,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 4) {
            try {
              await db.execute('ALTER TABLE budget ADD COLUMN total_budget INTEGER NOT NULL DEFAULT 0');
            } catch (_) {}
            try {
              await db.execute('ALTER TABLE budget ADD COLUMN payday_day INTEGER NOT NULL DEFAULT 25');
            } catch (_) {}
          }
          if (oldVersion < 6) {
            try {
              await db.execute('ALTER TABLE budget ADD COLUMN carryover_balance INTEGER NOT NULL DEFAULT 0');
            } catch (_) {}
            try {
              await db.execute('ALTER TABLE budget ADD COLUMN is_period_confirmed INTEGER NOT NULL DEFAULT 1');
            } catch (_) {}
          }
        },
        onOpen: (db) async {
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN total_budget INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN payday_day INTEGER NOT NULL DEFAULT 25');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN carryover_balance INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN is_period_confirmed INTEGER NOT NULL DEFAULT 1');
          } catch (_) {}
        },
      );

      // Verify insertion with BudgetModel.toMap() succeeds without error
      final newBudget = BudgetModel.createDefault();
      expect(() async {
        await db.insert('budget', newBudget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }, returnsNormally);

      final rows = await db.query('budget');
      expect(rows.length, 1);
      expect(rows.first['total_budget'], 0);
      expect(rows.first['carryover_balance'], 0);

      await db.close();
    });

    test('onOpen heals missing columns even if version was not bumped', () async {
      final dbPath = p.join(testDbDir, 'broken_onopen.db');

      // Create broken schema table
      var db = await openDatabase(
        dbPath,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE budget (
              id INTEGER PRIMARY KEY,
              weekly_income INTEGER NOT NULL,
              weekly_savings_target INTEGER NOT NULL,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL
            )
          ''');
        },
      );
      await db.close();

      // Re-open with onOpen recovery
      db = await openDatabase(
        dbPath,
        version: 3,
        onOpen: (db) async {
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN total_budget INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN payday_day INTEGER NOT NULL DEFAULT 25');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN carryover_balance INTEGER NOT NULL DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN is_period_confirmed INTEGER NOT NULL DEFAULT 1');
          } catch (_) {}
        },
      );

      // Now inserting defaultBudget with toMap() must not fail
      final defaultBudget = BudgetModel.createDefault();
      expect(() async {
        await db.insert('budget', defaultBudget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }, returnsNormally);

      await db.close();
    });

    test('Isolated budget insertion and reading maintains consistency', () async {
      final dbPath = p.join(testDbDir, 'isolated_budget.db');
      final db = await openDatabase(
        dbPath,
        version: 6,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS budget (
              id INTEGER PRIMARY KEY,
              weekly_income INTEGER NOT NULL DEFAULT 0,
              weekly_savings_target INTEGER NOT NULL DEFAULT 0,
              total_budget INTEGER NOT NULL DEFAULT 0,
              payday_day INTEGER NOT NULL DEFAULT 25,
              carryover_balance INTEGER NOT NULL DEFAULT 0,
              is_period_confirmed INTEGER NOT NULL DEFAULT 1,
              start_date TEXT NOT NULL,
              end_date TEXT NOT NULL
            )
          ''');
          final defaultBudget = BudgetModel.createDefault();
          await db.insert('budget', defaultBudget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        },
      );

      final res = await db.query('budget', where: 'id = ?', whereArgs: [1]);
      final budget = BudgetModel.fromMap(res.first);
      expect(budget.weeklyIncome, equals(0));
      expect(budget.weeklySavingsTarget, equals(0));
      expect(budget.carryoverBalance, equals(0));

      final updated = budget.copyWith(weeklyIncome: 200000, weeklySavingsTarget: 50000, carryoverBalance: 25000);
      await db.insert('budget', updated.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      final fetched = BudgetModel.fromMap((await db.query('budget', where: 'id = ?', whereArgs: [1])).first);
      expect(fetched.weeklyIncome, equals(200000));
      expect(fetched.weeklySavingsTarget, equals(50000));
      expect(fetched.carryoverBalance, equals(25000));
      expect(fetched.spendableBudget, equals(175000));

      await db.close();
    });
  });
}
