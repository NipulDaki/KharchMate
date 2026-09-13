import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/enum/payment_mode.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/transaction/presentation/add_transaction_screen.dart';
import 'package:kharch_mate/ui/transaction/presentation/transaction_details_screen.dart';
import 'package:kharch_mate/ui/transaction/presentation/transactions_screen.dart';
import 'package:kharch_mate/widgets/month_year_picker_sheet.dart';
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

  testWidgets('TransactionsScreen renders header, tabs, search bar, and list', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      final now = DateTime.now();
      final expenseCats = await databaseService.getExpenseCategories();
      final incomeCats = await databaseService.getIncomeCategories();

      final foodCat = expenseCats.firstWhere((c) => c.name == 'Food');
      final salaryCat = incomeCats.firstWhere((c) => c.name == 'Salary');

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Food',
          amount: 350.0,
          type: TransactionType.expense,
          categoryId: foodCat.id!,
          categoryName: foodCat.name,
          categoryIcon: foodCat.icon,
          categoryColor: foodCat.color,
          paymentMethodName: 'HDFC Bank',
          date: now,
          note: 'Lunch at restaurant',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await databaseService.insertTransaction(
        TransactionItem(
          title: 'Salary',
          amount: 80000.0,
          type: TransactionType.income,
          categoryId: salaryCat.id!,
          categoryName: salaryCat.name,
          categoryIcon: salaryCat.icon,
          categoryColor: salaryCat.color,
          paymentMethodName: 'Bank Transfer',
          date: now,
          note: 'Monthly salary',
          createdAt: now,
          updatedAt: now,
        ),
      );
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionsScreen(),
      ),
    );

    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();

    // Verify Header
    expect(find.text('Transactions'), findsWidgets);

    // Verify Segment Tabs
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);

    // Verify Search Bar
    expect(find.text('Search transactions...'), findsOneWidget);

    // Verify transactions in list
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    // Filter by Income tab
    await tester.tap(find.text('Income'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);

    // Filter by Expense tab
    await tester.tap(find.text('Expense'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });

  testWidgets(
    'MonthYearPickerSheet allows navigating years and selecting month',
    (WidgetTester tester) async {
      DateTime? selectedDate;
      bool allMonthsChosen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  final result = await showMonthYearPickerSheet(
                    context: ctx,
                    initialDate: DateTime(2026, 9, 1),
                    allowAllMonths: true,
                  );
                  if (result != null) {
                    selectedDate = result.date;
                    allMonthsChosen = result.isAllMonths;
                  }
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Select Month'), findsOneWidget);
      expect(find.text('All Months'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
      expect(find.text('Jan'), findsOneWidget);
      expect(find.text('Dec'), findsOneWidget);

      // Tap next year button (advance to 2027)
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      expect(find.text('2027'), findsOneWidget);

      // Select February
      await tester.tap(find.text('Feb'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(selectedDate?.year, equals(2027));
      expect(selectedDate?.month, equals(2));
      expect(allMonthsChosen, isFalse);
    },
  );

  testWidgets(
    'TransactionDetailsScreen renders white background, details and delete action',
    (WidgetTester tester) async {
      final now = DateTime(2026, 9, 12, 13, 30);
      late TransactionItem inserted;

      await tester.runAsync(() async {
        final expenseCats = await databaseService.getExpenseCategories();
        final foodCat = expenseCats.firstWhere((c) => c.name == 'Food');

        inserted = await databaseService.insertTransaction(
          TransactionItem(
            title: 'Food',
            amount: 350.0,
            type: TransactionType.expense,
            categoryId: foodCat.id!,
            categoryName: foodCat.name,
            categoryIcon: foodCat.icon,
            categoryColor: foodCat.color,
            paymentMethodName: 'HDFC Bank',
            date: now,
            note: 'Restaurant Lunch',
            createdAt: now,
            updatedAt: now,
          ),
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetailsScreen(transaction: inserted),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Check title and details
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Restaurant Lunch'), findsWidgets);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Delete to open confirmation dialog
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Delete Transaction'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        findsOneWidget,
      );

      // Verify AlertDialog has white background
      final alertFinder = find.byType(AlertDialog);
      expect(alertFinder, findsOneWidget);
      final alertDialog = tester.widget<AlertDialog>(alertFinder);
      expect(alertDialog.backgroundColor, Colors.white);
      expect(alertDialog.surfaceTintColor, Colors.transparent);

      // Cancel delete
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Delete Transaction'), findsNothing);
    },
  );

  testWidgets(
    'AddTransactionScreen supports editing existing transaction',
    (WidgetTester tester) async {
      final now = DateTime(2026, 9, 10);
      late TransactionItem inserted;

      await tester.runAsync(() async {
        final expenseCats = await databaseService.getExpenseCategories();
        final foodCat = expenseCats.firstWhere((c) => c.name == 'Food');

        inserted = await databaseService.insertTransaction(
          TransactionItem(
            title: 'Food',
            amount: 350.0,
            type: TransactionType.expense,
            categoryId: foodCat.id!,
            categoryName: foodCat.name,
            categoryIcon: foodCat.icon,
            categoryColor: foodCat.color,
            paymentMethodName: 'Cash',
            date: now,
            note: 'Old note',
            createdAt: now,
            updatedAt: now,
          ),
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AddTransactionScreen(initialTransaction: inserted),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();

      // Verify edit mode title and prefilled values
      expect(find.text('Edit Transaction'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Old note'), findsOneWidget);
    },
  );

  test('DatabaseService updates and deletes a transaction item correctly', () async {
    final now = DateTime.now();
    final expenseCats = await databaseService.getExpenseCategories();
    final foodCat = expenseCats.firstWhere((c) => c.name == 'Food');

    final item = await databaseService.insertTransaction(
      TransactionItem(
        title: 'Food',
        amount: 350.0,
        type: TransactionType.expense,
        categoryId: foodCat.id!,
        categoryName: foodCat.name,
        categoryIcon: foodCat.icon,
        categoryColor: foodCat.color,
        paymentMethodName: PaymentMode.cash.displayName,
        date: now,
        note: 'Before edit',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(item.id, isNotNull);

    // Update
    final updated = item.copyWith(
      amount: 550.0,
      note: 'After edit',
    );
    final savedUpdate = await databaseService.updateTransaction(updated);
    expect(savedUpdate?.amount, equals(550.0));
    expect(savedUpdate?.note, equals('After edit'));

    // Delete
    final deletedCount = await databaseService.deleteTransaction(item.id!);
    expect(deletedCount, equals(1));

    final fetchAfterDelete = await databaseService.getTransactionById(item.id!);
    expect(fetchAfterDelete, isNull);
  });
}
