import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/enum/payment_mode.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/reports/presentation/reports_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabase appDatabase;
  late DatabaseService databaseService;

  setUp(() async {
    if (serviceLocator.isRegistered<AppDatabase>()) {
      await serviceLocator.reset();
    }
    appDatabase = AppDatabase();
    await appDatabase.init(customPath: inMemoryDatabasePath);
    databaseService = DatabaseService(appDatabase: appDatabase);

    await databaseService.ensurePredefinedCategories();
    await databaseService.saveUserProfile(
      UserProfile(
        name: 'Nipul Daki',
        email: 'nipul@example.com',
        currencyCode: 'INR',
        currencySymbol: '₹',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    serviceLocator
      ..registerSingleton<AppDatabase>(appDatabase)
      ..registerLazySingleton<DatabaseService>(() => databaseService);
  });

  tearDown(() async {
    await appDatabase.close();
    await serviceLocator.reset();
  });

  testWidgets('ReportsScreen renders all components matching mockup', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();

    await tester.runAsync(() async {
      final expenseCategories = await databaseService.getExpenseCategories();
      final incomeCategories = await databaseService.getIncomeCategories();

      final foodCat = expenseCategories.firstWhere((c) => c.name == 'Food');
      final rentCat = expenseCategories.firstWhere((c) => c.name == 'Rent');
      final salaryCat = incomeCategories.firstWhere((c) => c.name == 'Salary');

      // Income transaction
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Monthly Salary',
          amount: 80000,
          type: TransactionType.income,
          categoryId: salaryCat.id!,
          categoryName: salaryCat.name,
          categoryColor: salaryCat.color,
          categoryIcon: salaryCat.icon,
          paymentMethodName: PaymentMode.bank.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Expense transactions
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Apartment Rent',
          amount: 20000,
          type: TransactionType.expense,
          categoryId: rentCat.id!,
          categoryName: rentCat.name,
          categoryColor: rentCat.color,
          categoryIcon: rentCat.icon,
          paymentMethodName: PaymentMode.bank.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Groceries',
          amount: 7500,
          type: TransactionType.expense,
          categoryId: foodCat.id!,
          categoryName: foodCat.name,
          categoryColor: foodCat.color,
          categoryIcon: foodCat.icon,
          paymentMethodName: PaymentMode.cash.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportsScreen(),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Title & Segmented Tabs
    expect(find.text('Reports'), findsNWidgets(2)); // Screen header & BottomNav item
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Trends'), findsOneWidget);

    // Verify Total Income and Total Expense Cards
    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('₹80,000'), findsOneWidget);
    expect(find.text('Total Expense'), findsOneWidget);
    expect(find.text('₹27,500'), findsOneWidget);

    // Verify Savings Card
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('₹52,500'), findsOneWidget);

    // Verify Bar Chart Section
    expect(find.text('Income vs Expense'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);

    // Verify Top Spending Categories Section and correct icons
    expect(find.text('Top Spending Categories'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Icon && w.icon == Icons.home_rounded && w.size == 20), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Icon && w.icon == Icons.restaurant && w.size == 20), findsOneWidget);

    // Test switching to Category tab
    await tester.tap(find.text('Category'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);

    // Test switching to Trends tab
    await tester.tap(find.text('Trends'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Monthly Trends (Last 6 Months)'), findsOneWidget);

    // Switch back to Overview
    await tester.tap(find.text('Overview'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Income vs Expense'), findsOneWidget);
  });

  testWidgets('Top Spending Categories displays correct icons for various custom and default categories', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();

    await tester.runAsync(() async {
      // Insert custom categories with various icons
      final groceryCat = await databaseService.insertCategory(
        CategoryModel(
          name: 'Groceries',
          type: CategoryType.expense,
          icon: 'shopping_cart',
          color: '#4CAF50',
          createdAt: now,
        ),
      );

      final healthCat = await databaseService.insertCategory(
        CategoryModel(
          name: 'Health & Medical',
          type: CategoryType.expense,
          icon: 'medical_services',
          color: '#E91E63',
          createdAt: now,
        ),
      );

      final gamingCat = await databaseService.insertCategory(
        CategoryModel(
          name: 'Gaming',
          type: CategoryType.expense,
          icon: 'sports_esports',
          color: '#9C27B0',
          createdAt: now,
        ),
      );

      // Insert expense transactions for each
      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Weekly Market',
          amount: 5000,
          type: TransactionType.expense,
          categoryId: groceryCat.id!,
          categoryName: groceryCat.name,
          categoryColor: groceryCat.color,
          categoryIcon: groceryCat.icon,
          paymentMethodName: PaymentMode.cash.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Pharmacy',
          amount: 3000,
          type: TransactionType.expense,
          categoryId: healthCat.id!,
          categoryName: healthCat.name,
          categoryColor: healthCat.color,
          categoryIcon: healthCat.icon,
          paymentMethodName: PaymentMode.upi.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Steam Game',
          amount: 1500,
          type: TransactionType.expense,
          categoryId: gamingCat.id!,
          categoryName: gamingCat.name,
          categoryColor: gamingCat.color,
          categoryIcon: gamingCat.icon,
          paymentMethodName: PaymentMode.card.displayName,
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportsScreen(),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify all categories appear in Top Spending Categories
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Health & Medical'), findsOneWidget);
    expect(find.text('Gaming'), findsOneWidget);

    // Verify their respective icons render properly instead of generic category_rounded
    expect(find.byIcon(Icons.shopping_cart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);
  });
}
