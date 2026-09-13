import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/database/migrations/database_migration.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabase appDatabase;
  late DatabaseService databaseService;

  setUp(() async {
    appDatabase = AppDatabase();
    await appDatabase.init(customPath: inMemoryDatabasePath);
    databaseService = DatabaseService(appDatabase: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  group('SQLite Database Initialization & Migrations', () {
    test('Initializes schema and creates all required tables', () async {
      final db = appDatabase.db;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains(DatabaseConstants.tableUsers));
      expect(tableNames, contains(DatabaseConstants.tableCategories));
      expect(tableNames, contains(DatabaseConstants.tablePaymentMethods));
      expect(tableNames, contains(DatabaseConstants.tableTransactions));
      expect(tableNames, contains(DatabaseConstants.tableBudgets));
      expect(tableNames, contains(DatabaseConstants.tableMigrations));
    });

    test('Seeds default categories and payment methods automatically', () async {
      final categories = await databaseService.getAllCategories();
      expect(categories, isNotEmpty);

      final categoryNames = categories.map((c) => c.name).toList();
      expect(categoryNames, contains('Food'));
      expect(categoryNames, contains('Rent'));
      expect(categoryNames, contains('Transport'));
      expect(categoryNames, contains('Salary'));

      final paymentMethods = await databaseService.getPaymentMethods();
      expect(paymentMethods, isNotEmpty);
      final methodNames = paymentMethods.map((pm) => pm.name).toList();
      expect(methodNames, contains('Cash'));
      expect(methodNames, contains('HDFC Bank'));
    });

    test('Future migration runner executes and records new versions', () async {
      final runner = MigrationRunner(
        migrations: [
          ...AppDatabase.registeredMigrations,
          _MockMigrationV2(),
        ],
      );

      final db = appDatabase.db;
      await runner.runMigrations(db, 1, 2);

      final applied = await runner.getAppliedMigrations(db);
      final versions = applied.map((m) => m['version'] as int).toList();
      expect(versions, contains(2));

      // Verify column added by migration v2 exists
      final columns = await db.rawQuery("PRAGMA table_info(${DatabaseConstants.tableTransactions});");
      final colNames = columns.map((c) => c['name'] as String).toList();
      expect(colNames, contains('test_tag'));
    });
  });

  group('User Profile & Onboarding Operations', () {
    test('Initially hasUser() returns false, then true after name saved', () async {
      expect(await databaseService.hasUser(), isFalse);

      final user = await databaseService.saveUserName('Nipul Daki');
      expect(user.name, equals('Nipul Daki'));
      expect(user.initials, equals('ND'));

      expect(await databaseService.hasUser(), isTrue);

      final fetched = await databaseService.getUserProfile();
      expect(fetched?.name, equals('Nipul Daki'));
      expect(fetched?.currencySymbol, equals('₹'));
    });

    test('Updates user preferences (dark mode)', () async {
      await databaseService.saveUserName('Nipul');
      await databaseService.updateDarkMode(true);

      final user = await databaseService.getUserProfile();
      expect(user?.isDarkMode, isTrue);
    });
  });

  group('Transactions & Summary Operations', () {
    test('Inserts transactions and calculates monthly summaries correctly', () async {
      final expenseCategories = await databaseService.getExpenseCategories();
      final incomeCategories = await databaseService.getIncomeCategories();

      final foodCategory = expenseCategories.firstWhere((c) => c.name == 'Food');
      final rentCategory = expenseCategories.firstWhere((c) => c.name == 'Rent');
      final salaryCategory = incomeCategories.firstWhere((c) => c.name == 'Salary');

      final now = DateTime(2026, 9, 12, 13, 30);

      // Add Income: Salary ₹80,000
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Monthly Salary',
          amount: 80000.0,
          type: TransactionType.income,
          categoryId: salaryCategory.id!,
          date: now,
          paymentMethodName: 'HDFC Bank',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Add Expense: Rent ₹12,000
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'House Rent',
          amount: 12000.0,
          type: TransactionType.expense,
          categoryId: rentCategory.id!,
          date: now,
          paymentMethodName: 'Bank Transfer',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Add Expense: Food ₹350
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Lunch',
          amount: 350.0,
          type: TransactionType.expense,
          categoryId: foodCategory.id!,
          note: 'Restaurant',
          date: now,
          paymentMethodName: 'HDFC Bank',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Check Recent Transactions
      final recent = await databaseService.getRecentTransactions(limit: 5);
      expect(recent.length, equals(3));
      expect(recent.first.categoryName, isNotNull);

      // Check Monthly Summary
      final summary = await databaseService.getMonthlySummary(9, 2026);
      expect(summary.totalIncome, equals(80000.0));
      expect(summary.totalExpense, equals(12350.0));
      expect(summary.totalBalance, equals(67650.0));
      expect(summary.savings, equals(67650.0));

      // Check Category Spending Breakdown
      final breakdown = summary.categoryBreakdown;
      expect(breakdown, isNotEmpty);
      expect(breakdown.first.categoryName, equals('Rent'));
      expect(breakdown.first.amount, equals(12000.0));
    });

    test('Updates and deletes transactions', () async {
      final categories = await databaseService.getExpenseCategories();
      final food = categories.firstWhere((c) => c.name == 'Food');
      final date = DateTime.now();

      final tx = await databaseService.insertTransaction(
        TransactionItem(
          title: 'Dinner',
          amount: 500.0,
          type: TransactionType.expense,
          categoryId: food.id!,
          date: date,
          createdAt: date,
          updatedAt: date,
        ),
      );

      expect(tx.id, isNotNull);

      // Update
      final updated = await databaseService.updateTransaction(
        tx.copyWith(amount: 650.0, title: 'Dinner with friends'),
      );
      expect(updated?.amount, equals(650.0));
      expect(updated?.title, equals('Dinner with friends'));

      // Delete
      final deletedCount = await databaseService.deleteTransaction(tx.id!);
      expect(deletedCount, equals(1));

      final fetched = await databaseService.getTransactionById(tx.id!);
      expect(fetched, isNull);
    });
  });

  group('Budget Operations', () {
    test('Sets and retrieves monthly and category budgets with alert status', () async {
      final categories = await databaseService.getExpenseCategories();
      final food = categories.firstWhere((c) => c.name == 'Food');
      final now = DateTime(2026, 9, 15);

      // Set Monthly Budget limit: ₹40,000
      await databaseService.setOverallBudget(
        amountLimit: 40000.0,
        month: 9,
        year: 2026,
      );

      // Set Food Category Budget limit: ₹1,000
      await databaseService.setCategoryBudget(
        categoryId: food.id!,
        amountLimit: 1000.0,
        month: 9,
        year: 2026,
      );

      // Add expense in food: ₹850 (85% of budget - triggers near limit alert)
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Grocery',
          amount: 850.0,
          type: TransactionType.expense,
          categoryId: food.id!,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final overall = await databaseService.getOverallBudget(9, 2026);
      expect(overall?.amountLimit, equals(40000.0));
      expect(overall?.spentAmount, equals(850.0));
      expect(overall?.remainingAmount, equals(39150.0));

      final categoryBudgets = await databaseService.getCategoryBudgets(9, 2026);
      expect(categoryBudgets, isNotEmpty);
      final foodBudget = categoryBudgets.firstWhere((b) => b.categoryId == food.id);
      expect(foodBudget.spentAmount, equals(850.0));
      expect(foodBudget.spentPercentageInt, equals(85));
      expect(foodBudget.isNearLimit, isTrue);

      final alert = await databaseService.getBudgetAlert(9, 2026);
      expect(alert, contains('close to your limit'));
    });
  });
}

class _MockMigrationV2 extends DatabaseMigration {
  @override
  int get version => 2;

  @override
  String get description => 'Add test_tag to transactions table';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await db.execute('ALTER TABLE ${DatabaseConstants.tableTransactions} ADD COLUMN test_tag TEXT;');
  }

  @override
  Future<void> down(DatabaseExecutor db) async {
    // SQLite alter table drop column
  }
}
