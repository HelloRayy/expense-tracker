import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/budget/models/budget_model.dart';
import '../../features/budget/models/expense_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  factory DbHelper() => instance;
  DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jajan_tracker.db');

    return await openDatabase(
      path,
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

        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount INTEGER NOT NULL,
            note TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses (created_at DESC)
        ''');

        // Insert default initial weekly budget (Rp 0 income, Rp 0 savings target)
        final defaultBudget = BudgetModel.createDefault();
        await db.insert('budget', defaultBudget.toMap());
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses (created_at DESC)
          ''');
        }
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN weekly_income INTEGER DEFAULT 0');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE budget ADD COLUMN weekly_savings_target INTEGER DEFAULT 0');
          } catch (_) {}

          final now = DateTime.now();
          final start = BudgetModel.getMondayOfWeek(now).toIso8601String();
          final end = BudgetModel.getSundayOfWeek(now).toIso8601String();
          await db.rawUpdate(
            'UPDATE budget SET start_date = ?, end_date = ? WHERE id = 1',
            [start, end],
          );
        }
      },
    );
  }

  // Budget operations
  Future<BudgetModel> getBudget() async {
    final db = await database;
    final res = await db.query('budget', where: 'id = ?', whereArgs: [1], limit: 1);
    if (res.isNotEmpty) {
      return BudgetModel.fromMap(res.first);
    }
    final defaultBudget = BudgetModel.createDefault();
    await db.insert('budget', defaultBudget.toMap());
    return defaultBudget;
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'budget',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Expense operations
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<List<ExpenseModel>> getExpensesForPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final res = await db.query(
      'expenses',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return res.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<int> getTotalSpentForPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE created_at >= ? AND created_at <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toInt();
    }
    return 0;
  }

  Future<List<ExpenseModel>> getRecentExpenses({int limit = 20}) async {
    final db = await database;
    final res = await db.query(
      'expenses',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return res.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  Future<int> getSpentUntilYesterday(DateTime start) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayEnd = todayStart.subtract(const Duration(milliseconds: 1));
    if (yesterdayEnd.isBefore(start)) return 0;
    return await getTotalSpentForPeriod(start, yesterdayEnd);
  }

  Future<int> getSpentToday() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return await getTotalSpentForPeriod(todayStart, todayEnd);
  }
}
