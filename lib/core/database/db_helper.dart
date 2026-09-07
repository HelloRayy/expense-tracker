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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE budget (
            id INTEGER PRIMARY KEY,
            total_budget INTEGER NOT NULL,
            payday_day INTEGER NOT NULL,
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

        // Insert default initial budget (e.g. Rp 1.500.000, payday 25th)
        final defaultBudget = BudgetModel.createDefault(total: 1500000, payday: 25);
        await db.insert('budget', defaultBudget.toMap());
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses (created_at DESC)
          ''');
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
}
