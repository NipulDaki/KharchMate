import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/enum/payment_mode.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/transaction/presentation/add_transaction_screen.dart';
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

  testWidgets('AddTransactionScreen renders all fields matching mockup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Verify Title & Type switcher
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);

    // Verify Fields
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Enter amount'), findsOneWidget);

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Select category'), findsOneWidget);

    expect(find.text('Date'), findsOneWidget);

    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Select method'), findsOneWidget);

    expect(find.text('Note (Optional)'), findsOneWidget);
    expect(find.text('Add note'), findsOneWidget);

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Validation requires Amount, Category, and Payment Method, but Note is optional', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Tap Save with empty fields
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify validation errors appear
    expect(find.text('Please enter an amount'), findsOneWidget);
    expect(find.text('Please select a category'), findsOneWidget);
    expect(find.text('Please select a payment method'), findsOneWidget);
  });

  testWidgets('Type toggle changes categories list between Expense and Income', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Initially Expense: Open category dropdown
    await tester.tap(find.text('Select category'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Expense categories are present
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    // Close category sheet
    Navigator.of(tester.element(find.text('Food'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Toggle to Income
    await tester.tap(find.text('Income'));
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Open category dropdown for Income
    await tester.tap(find.text('Select category'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Income categories are present
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  test('DatabaseService inserts and queries a new TransactionItem with PaymentMode', () async {
    final categories = await databaseService.getExpenseCategories();
    expect(categories, isNotEmpty);
    final foodCat = categories.firstWhere((c) => c.name == 'Food');

    final item = TransactionItem(
      title: foodCat.name,
      amount: 1250.50,
      type: TransactionType.expense,
      categoryId: foodCat.id!,
      categoryName: foodCat.name,
      categoryIcon: foodCat.icon,
      categoryColor: foodCat.color,
      paymentMethodName: PaymentMode.card.displayName,
      date: DateTime.now(),
      note: 'Dinner with friends',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final inserted = await databaseService.insertTransaction(item);
    expect(inserted.id, isNotNull);

    final recent = await databaseService.getRecentTransactions(limit: 5);
    expect(recent, isNotEmpty);

    final saved = recent.first;
    expect(saved.amount, equals(1250.50));
    expect(saved.type, equals(TransactionType.expense));
    expect(saved.categoryName, equals('Food'));
    expect(saved.paymentMethodName, equals('Card'));
    expect(saved.note, equals('Dinner with friends'));
  });

  test('PaymentMode enum has all required modes with displayName and icons', () {
    expect(PaymentMode.values, contains(PaymentMode.upi));
    expect(PaymentMode.values, contains(PaymentMode.card));
    expect(PaymentMode.values, contains(PaymentMode.bank));
    expect(PaymentMode.values, contains(PaymentMode.cash));

    expect(PaymentMode.upi.displayName, equals('UPI'));
    expect(PaymentMode.card.displayName, equals('Card'));
    expect(PaymentMode.bank.displayName, equals('Bank'));
    expect(PaymentMode.cash.displayName, equals('Cash'));
  });
}
