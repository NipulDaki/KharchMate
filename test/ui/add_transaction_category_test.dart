import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:kharch_mate/ui/transaction/presentation/add_transaction_screen.dart';

class FakeDatabaseService extends Fake implements DatabaseService {
  final List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 1,
      name: 'Food & Dining',
      type: CategoryType.expense,
      icon: 'restaurant',
      color: '#FF5722',
      isDefault: true,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  final List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 2,
      name: 'Salary',
      type: CategoryType.income,
      icon: 'attach_money',
      color: '#4CAF50',
      isDefault: true,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  Stream<UserProfile> get onUserProfileChanged => const Stream.empty();

  @override
  Stream<void> get onTransactionChanged => const Stream.empty();

  @override
  Future<UserProfile?> getUserProfile() async {
    return UserProfile(
      id: 1,
      name: 'Tester',
      currencyCode: 'INR',
      currencySymbol: '₹',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
  }

  @override
  Future<void> ensurePredefinedCategories() async {}

  @override
  Future<List<CategoryModel>> getExpenseCategories() async => expenseCategories;

  @override
  Future<List<CategoryModel>> getIncomeCategories() async => incomeCategories;
}

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    serviceLocator.reset();

    final secureStorage = SecureStorageService();
    // Mark coach marks seen so they don't block tests
    await secureStorage.markCoachMarkSeen(SecureStorageService.keyCoachMarkAddTransaction);

    final fakeDbService = FakeDatabaseService();

    serviceLocator
      ..registerSingleton<DatabaseService>(fakeDbService)
      ..registerSingleton<SecureStorageService>(secureStorage);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  testWidgets('Add Transaction shows "+ Add Category" button and opens dropdown with "+ Add New Category" action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check that 'Category' label is visible directly above the category dropdown
    expect(find.text('Category'), findsOneWidget);

    // Tap on the category selector dropdown
    final categorySelector = find.text('Select category');
    expect(categorySelector, findsOneWidget);
    await tester.tap(categorySelector);
    await tester.pumpAndSettle();

    // Verify the bottom sheet displays '+ Add New Expense Category' and 'Add New'
    expect(find.text('Add New'), findsOneWidget);
    expect(find.text('+ Add New Expense Category'), findsOneWidget);
  });

  testWidgets('Selecting a category after entering amount does not refocus amount field', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddTransactionScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Focus amount field and enter amount
    final amountFinder = find.byType(TextFormField).first;
    await tester.tap(amountFinder);
    await tester.enterText(amountFinder, '250');
    await tester.pumpAndSettle();

    final EditableText editableBefore = tester.widget(find.byType(EditableText).first);
    expect(editableBefore.focusNode.hasFocus, isTrue, reason: 'Amount should be focused after entering text');

    // 2. Tap category dropdown
    final categorySelector = find.text('Select category');
    await tester.tap(categorySelector);
    await tester.pumpAndSettle();

    // 3. Select category from the bottom sheet
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();

    // 4. Verify category is selected
    expect(find.text('Food & Dining'), findsOneWidget);

    // 5. Verify amount field does NOT have focus
    final EditableText editableAfter = tester.widget(find.byType(EditableText).first);
    expect(editableAfter.focusNode.hasFocus, isFalse, reason: 'Amount field should not regain focus after category selection');
  });
}
