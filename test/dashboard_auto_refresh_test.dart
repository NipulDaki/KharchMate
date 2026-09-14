import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/enum/payment_mode.dart';
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

  testWidgets('DashboardScreen auto-refreshes when a new transaction is added', (
    WidgetTester tester,
  ) async {
    // 1. Pump Dashboard initially with no transactions
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );

    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Initially: balance is 0 and empty state is shown
    expect(find.text('₹0'), findsWidgets);
    expect(find.text('No transactions yet. Tap \'+\' below to add your first expense or income!'), findsOneWidget);

    // 2. Insert a new transaction via DatabaseService (simulating adding a transaction)
    await tester.runAsync(() async {
      final categories = await databaseService.getExpenseCategories();
      final foodCat = categories.firstWhere((c) => c.name == 'Food');

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Dinner Pizza',
          amount: 850,
          type: TransactionType.expense,
          categoryId: foodCat.id!,
          categoryName: foodCat.name,
          categoryColor: foodCat.color,
          categoryIcon: foodCat.icon,
          paymentMethodName: PaymentMode.cash.displayName,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Wait a moment for the event stream and data reload
      await Future.delayed(const Duration(milliseconds: 300));
    });

    // 3. Pump frames without calling RefreshIndicator onRefresh
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Verify Dashboard automatically updated!
    expect(find.text('Dinner Pizza'), findsOneWidget);
    expect(find.text('₹850'), findsWidgets);
    expect(find.text('No transactions yet. Tap \'+\' below to add your first expense or income!'), findsNothing);
  });
}
