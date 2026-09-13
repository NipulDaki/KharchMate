import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
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
}
