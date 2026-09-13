import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/database/migrations/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Migration V1: Initial schema creation and default seed data.
class MigrationV1InitialSchema extends DatabaseMigration {
  const MigrationV1InitialSchema();

  @override
  int get version => 1;

  @override
  String get description =>
      'Initial schema: users, categories, payment_methods, transactions, budgets';

  @override
  Future<void> up(DatabaseExecutor db) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableUsers} (
        ${DatabaseConstants.colUserId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colUserName} TEXT NOT NULL,
        ${DatabaseConstants.colUserEmail} TEXT,
        ${DatabaseConstants.colUserCurrencyCode} TEXT NOT NULL DEFAULT 'INR',
        ${DatabaseConstants.colUserCurrencySymbol} TEXT NOT NULL DEFAULT '₹',
        ${DatabaseConstants.colUserIsDarkMode} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colUserCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUserUpdatedAt} TEXT NOT NULL
      );
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableCategories} (
        ${DatabaseConstants.colCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colCategoryName} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryType} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryIcon} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryColor} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCategoryCreatedAt} TEXT NOT NULL
      );
    ''');

    // 3. Payment Methods Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tablePaymentMethods} (
        ${DatabaseConstants.colPaymentMethodId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colPaymentMethodName} TEXT NOT NULL,
        ${DatabaseConstants.colPaymentMethodType} TEXT NOT NULL,
        ${DatabaseConstants.colPaymentMethodIcon} TEXT,
        ${DatabaseConstants.colPaymentMethodIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colPaymentMethodCreatedAt} TEXT NOT NULL
      );
    ''');

    // 4. Transactions Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableTransactions} (
        ${DatabaseConstants.colTransactionId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colTransactionTitle} TEXT,
        ${DatabaseConstants.colTransactionAmount} REAL NOT NULL,
        ${DatabaseConstants.colTransactionType} TEXT NOT NULL,
        ${DatabaseConstants.colTransactionCategoryId} INTEGER NOT NULL,
        ${DatabaseConstants.colTransactionPaymentMethodId} INTEGER,
        ${DatabaseConstants.colTransactionPaymentMethodName} TEXT,
        ${DatabaseConstants.colTransactionDate} TEXT NOT NULL,
        ${DatabaseConstants.colTransactionNote} TEXT,
        ${DatabaseConstants.colTransactionReceiptPath} TEXT,
        ${DatabaseConstants.colTransactionCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colTransactionUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colTransactionCategoryId})
          REFERENCES ${DatabaseConstants.tableCategories} (${DatabaseConstants.colCategoryId})
          ON DELETE RESTRICT,
        FOREIGN KEY (${DatabaseConstants.colTransactionPaymentMethodId})
          REFERENCES ${DatabaseConstants.tablePaymentMethods} (${DatabaseConstants.colPaymentMethodId})
          ON DELETE SET NULL
      );
    ''');

    // Indexes for transactions
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_date
      ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colTransactionDate});
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_type
      ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colTransactionType});
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_category
      ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colTransactionCategoryId});
    ''');

    // 5. Budgets Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableBudgets} (
        ${DatabaseConstants.colBudgetId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.colBudgetCategoryId} INTEGER,
        ${DatabaseConstants.colBudgetIsOverall} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colBudgetAmountLimit} REAL NOT NULL,
        ${DatabaseConstants.colBudgetMonth} INTEGER NOT NULL,
        ${DatabaseConstants.colBudgetYear} INTEGER NOT NULL,
        ${DatabaseConstants.colBudgetCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colBudgetUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colBudgetCategoryId})
          REFERENCES ${DatabaseConstants.tableCategories} (${DatabaseConstants.colCategoryId})
          ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_budgets_month_year
      ON ${DatabaseConstants.tableBudgets} (${DatabaseConstants.colBudgetMonth}, ${DatabaseConstants.colBudgetYear});
    ''');

    // Seed default categories
    await _seedDefaultCategories(db);

    // Seed default payment methods
    await _seedDefaultPaymentMethods(db);
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableBudgets};');
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableTransactions};');
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tablePaymentMethods};');
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableCategories};');
    await db.execute('DROP TABLE IF EXISTS ${DatabaseConstants.tableUsers};');
  }

  Future<void> _seedDefaultCategories(DatabaseExecutor db) async {
    final now = DateTime.now().toIso8601String();

    final defaultCategories = [
      // Predefined Expense Categories
      {'name': 'Rent', 'type': 'expense', 'icon': 'home', 'color': '#26A69A'},
      {'name': 'Food', 'type': 'expense', 'icon': 'fastfood', 'color': '#FF9800'},
      {'name': 'Transport', 'type': 'expense', 'icon': 'directions_car', 'color': '#42A5F5'},
      {'name': 'Shopping', 'type': 'expense', 'icon': 'shopping_bag', 'color': '#7E57C2'},

      // Predefined Income Categories
      {'name': 'Salary', 'type': 'income', 'icon': 'account_balance_wallet', 'color': '#1A6C45'},
      {'name': 'Bonus', 'type': 'income', 'icon': 'stars', 'color': '#E91E63'},
    ];

    for (final cat in defaultCategories) {
      await db.insert(
        DatabaseConstants.tableCategories,
        {
          DatabaseConstants.colCategoryName: cat['name'],
          DatabaseConstants.colCategoryType: cat['type'],
          DatabaseConstants.colCategoryIcon: cat['icon'],
          DatabaseConstants.colCategoryColor: cat['color'],
          DatabaseConstants.colCategoryIsDefault: 1,
          DatabaseConstants.colCategoryCreatedAt: now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _seedDefaultPaymentMethods(DatabaseExecutor db) async {
    final now = DateTime.now().toIso8601String();

    final defaultPaymentMethods = [
      {'name': 'Cash', 'type': 'cash', 'icon': 'payments', 'is_default': 1},
      {'name': 'HDFC Bank', 'type': 'bank', 'icon': 'account_balance', 'is_default': 0},
      {'name': 'UPI', 'type': 'upi', 'icon': 'qr_code', 'is_default': 0},
      {'name': 'Credit Card', 'type': 'card', 'icon': 'credit_card', 'is_default': 0},
      {'name': 'Debit Card', 'type': 'card', 'icon': 'credit_card', 'is_default': 0},
    ];

    for (final pm in defaultPaymentMethods) {
      await db.insert(
        DatabaseConstants.tablePaymentMethods,
        {
          DatabaseConstants.colPaymentMethodName: pm['name'],
          DatabaseConstants.colPaymentMethodType: pm['type'],
          DatabaseConstants.colPaymentMethodIcon: pm['icon'],
          DatabaseConstants.colPaymentMethodIsDefault: pm['is_default'],
          DatabaseConstants.colPaymentMethodCreatedAt: now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
