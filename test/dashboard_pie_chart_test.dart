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
import 'package:kharch_mate/ui/dashboard/presentation/dashboard_screen.dart';
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
        name: 'Test User',
        email: 'test@example.com',
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

  testWidgets('DashboardScreen displays empty expense state when no transactions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Expense by Category'), findsOneWidget);
    expect(find.text('No expense recorded for this month'), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);
  });

  testWidgets('DashboardScreen displays PieChart using category colors from database', (
    WidgetTester tester,
  ) async {
    late final CategoryModel foodCat;
    late final CategoryModel rentCat;

    await tester.runAsync(() async {
      final now = DateTime.now();
      final categories = await databaseService.getExpenseCategories();
      expect(categories, isNotEmpty);

      foodCat = categories.firstWhere(
        (c) => c.name.toLowerCase() == 'food',
        orElse: () => categories[0],
      );
      rentCat = categories.firstWhere(
        (c) => c.name.toLowerCase() == 'rent',
        orElse: () => categories[1],
      );

      // Insert expense transactions for this month
      await databaseService.insertTransaction(
        TransactionItem(
          title: foodCat.name,
          amount: 500,
          type: TransactionType.expense,
          categoryId: foodCat.id!,
          categoryName: foodCat.name,
          categoryColor: foodCat.color,
          categoryIcon: foodCat.icon,
          paymentMethodName: PaymentMode.cash.displayName,
          date: now,
          note: 'Lunch',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await databaseService.insertTransaction(
        TransactionItem(
          title: rentCat.name,
          amount: 1500,
          type: TransactionType.expense,
          categoryId: rentCat.id!,
          categoryName: rentCat.name,
          categoryColor: rentCat.color,
          categoryIcon: rentCat.icon,
          paymentMethodName: PaymentMode.bank.displayName,
          date: now,
          note: 'House rent',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify PieChart is rendered
    final pieChartFinder = find.byType(PieChart);
    expect(pieChartFinder, findsOneWidget);

    final pieChartWidget = tester.widget<PieChart>(pieChartFinder);
    final sections = pieChartWidget.data.sections;

    // We inserted 2 expense categories
    expect(sections.length, 2);

    // Verify sections have colors matching the database category colors
    final sectionColors = sections.map((s) => s.color.toARGB32()).toList();
    expect(sectionColors, contains(foodCat.colorValue.toARGB32()));
    expect(sectionColors, contains(rentCat.colorValue.toARGB32()));
  });
}
