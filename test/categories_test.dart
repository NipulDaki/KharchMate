import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/financial_summary.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/categories/presentation/add_category_screen.dart';
import 'package:kharch_mate/ui/categories/presentation/categories_screen.dart';
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

    serviceLocator
      ..registerSingleton<AppDatabase>(appDatabase)
      ..registerLazySingleton<DatabaseService>(() => databaseService);
  });

  tearDown(() async {
    await appDatabase.close();
    await serviceLocator.reset();
  });

  testWidgets('CategoriesScreen displays predefined categories, tabs, and search', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CategoriesScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Verify Title & Tabs
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Expense'), findsAtLeastNWidgets(1));
    expect(find.text('Income'), findsAtLeastNWidgets(1));

    // Verify Predefined Expense Categories
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // Verify Predefined Income Categories
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);

    // Filter by tab 'Income'
    await tester.tap(find.text('Income').first);
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
    expect(find.text('Rent'), findsNothing);

    // Filter back to 'All'
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Test Search
    await tester.enterText(find.byType(TextField), 'Shopp');
    await tester.pumpAndSettle();

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });
  testWidgets('AddCategoryScreen renders UI controls and elements correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddCategoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Category'), findsOneWidget);
    expect(find.text('Select Icon'), findsOneWidget);
    expect(find.text('Select Color'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Enter category name
    await tester.enterText(find.byType(TextFormField), 'Freelance');
    await tester.pump();
    expect(find.text('Freelance'), findsOneWidget);

    // Toggle Income
    await tester.tap(find.text('Income'));
    await tester.pump();
  });

  test('DatabaseService inserts a new custom category into SQLite', () async {
    final newCategory = CategoryModel(
      name: 'Freelance Design',
      type: CategoryType.income,
      icon: 'laptop_mac',
      color: '#42A5F5',
      isDefault: false,
      createdAt: DateTime.now(),
    );

    final inserted = await databaseService.insertCategory(newCategory);
    expect(inserted.id, isNotNull);

    final all = await databaseService.getAllCategories();
    final names = all.map((c) => c.name).toList();
    expect(names, contains('Freelance Design'));

    final found = all.firstWhere((c) => c.name == 'Freelance Design');
    expect(found.type, equals(CategoryType.income));
    expect(found.icon, equals('laptop_mac'));
    expect(found.color, equals('#42A5F5'));
    expect(found.isDefault, isFalse);
  });

  test('DatabaseService deletes an existing category without transactions', () async {
    await databaseService.ensurePredefinedCategories();
    final initial = await databaseService.getAllCategories();
    expect(initial, isNotEmpty);

    final bonus = initial.firstWhere((c) => c.name == 'Bonus');
    await databaseService.deleteCategory(bonus.id!);

    final updated = await databaseService.getAllCategories();
    final names = updated.map((c) => c.name).toList();
    expect(names, isNot(contains('Bonus')));
  });

  test('CategoryModel.iconDataFrom resolves icons by key and fallback names correctly', () {
    expect(CategoryModel.iconDataFrom('fastfood'), equals(Icons.restaurant));
    expect(CategoryModel.iconDataFrom('home'), equals(Icons.home_rounded));
    expect(CategoryModel.iconDataFrom('directions_car'), equals(Icons.directions_car_rounded));
    expect(CategoryModel.iconDataFrom('shopping_bag'), equals(Icons.shopping_bag_rounded));
    expect(CategoryModel.iconDataFrom('shopping_cart'), equals(Icons.shopping_cart_rounded));
    expect(CategoryModel.iconDataFrom('receipt_long'), equals(Icons.receipt_long_rounded));
    expect(CategoryModel.iconDataFrom('medical_services'), equals(Icons.medical_services_rounded));
    expect(CategoryModel.iconDataFrom('sports_esports'), equals(Icons.sports_esports_rounded));
    expect(CategoryModel.iconDataFrom('school'), equals(Icons.school_rounded));
    expect(CategoryModel.iconDataFrom('flight'), equals(Icons.flight_rounded));
    expect(CategoryModel.iconDataFrom('spa'), equals(Icons.spa_rounded));
    expect(CategoryModel.iconDataFrom('account_balance'), equals(Icons.account_balance_rounded));
    expect(CategoryModel.iconDataFrom('shield'), equals(Icons.shield_rounded));
    expect(CategoryModel.iconDataFrom('card_giftcard'), equals(Icons.card_giftcard_rounded));
    expect(CategoryModel.iconDataFrom('more_horiz'), equals(Icons.more_horiz_rounded));
    expect(CategoryModel.iconDataFrom('account_balance_wallet'), equals(Icons.account_balance_wallet_rounded));
    expect(CategoryModel.iconDataFrom('stars'), equals(Icons.stars_rounded));
    expect(CategoryModel.iconDataFrom('trending_up'), equals(Icons.trending_up_rounded));
    expect(CategoryModel.iconDataFrom('laptop_mac'), equals(Icons.laptop_mac_rounded));
    expect(CategoryModel.iconDataFrom('store'), equals(Icons.store_rounded));

    // Fallback when icon is generic 'category' or null
    expect(CategoryModel.iconDataFrom('category', 'Groceries'), equals(Icons.shopping_cart_rounded));
    expect(CategoryModel.iconDataFrom(null, 'Medical Checkup'), equals(Icons.medical_services_rounded));
    expect(CategoryModel.iconDataFrom('', 'Flight Tickets'), equals(Icons.flight_rounded));
    expect(CategoryModel.iconDataFrom('category', 'Tuition Fee'), equals(Icons.school_rounded));
    expect(CategoryModel.iconDataFrom('category', 'Electricity Bill'), equals(Icons.receipt_long_rounded));
    expect(CategoryModel.iconDataFrom('category', 'Gaming Console'), equals(Icons.sports_esports_rounded));
    expect(CategoryModel.iconDataFrom('category', 'Hair Salon'), equals(Icons.spa_rounded));
    expect(CategoryModel.iconDataFrom('category', 'Car Fuel'), equals(Icons.directions_car_rounded));
  });

  test('CategorySpending.iconData correctly resolves icons for various categories', () {
    const spending1 = CategorySpending(
      categoryId: 1,
      categoryName: 'Groceries',
      categoryIcon: 'shopping_cart',
      categoryColor: '#FF9800',
      amount: 5000,
      percentage: 50,
    );
    expect(spending1.iconData, equals(Icons.shopping_cart_rounded));

    const spending2 = CategorySpending(
      categoryId: 2,
      categoryName: 'Doctor & Hospital',
      categoryIcon: 'medical_services',
      categoryColor: '#EF5350',
      amount: 3000,
      percentage: 30,
    );
    expect(spending2.iconData, equals(Icons.medical_services_rounded));

    const spending3 = CategorySpending(
      categoryId: 3,
      categoryName: 'Flight Tickets',
      categoryIcon: 'flight',
      categoryColor: '#42A5F5',
      amount: 2000,
      percentage: 20,
    );
    expect(spending3.iconData, equals(Icons.flight_rounded));

    // Fallback based on name when icon is category
    const spending4 = CategorySpending(
      categoryId: 4,
      categoryName: 'Apartment Rent',
      categoryIcon: 'category',
      categoryColor: '#26A69A',
      amount: 15000,
      percentage: 80,
    );
    expect(spending4.iconData, equals(Icons.home_rounded));
  });
}
