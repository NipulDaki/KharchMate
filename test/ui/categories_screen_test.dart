import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:kharch_mate/ui/categories/presentation/add_category_screen.dart';
import 'package:kharch_mate/ui/categories/presentation/categories_screen.dart';

class FakeDatabaseService extends Fake implements DatabaseService {
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 1,
      name: 'Food',
      type: CategoryType.expense,
      icon: 'fastfood',
      color: '#FF9800',
      isDefault: true,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  Future<void> ensurePredefinedCategories() async {}

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return List.from(_categories);
  }

  @override
  Future<CategoryModel> insertCategory(CategoryModel category) async {
    final inserted = category.copyWith(id: _categories.length + 1);
    _categories.add(inserted);
    return inserted;
  }
}

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    serviceLocator.reset();

    final secureStorage = SecureStorageService();
    await secureStorage.markCoachMarkSeen(SecureStorageService.keyCoachMarkAddCategory);

    final fakeDbService = FakeDatabaseService();

    serviceLocator
      ..registerSingleton<DatabaseService>(fakeDbService)
      ..registerSingleton<SecureStorageService>(secureStorage);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  testWidgets('Adding category from CategoriesScreen succeeds without type error', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.categories.path,
      routes: [
        GoRoute(
          path: AppRoutes.categories.path,
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: AppRoutes.addCategory.path,
          builder: (context, state) => const AddCategoryScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial category is shown
    expect(find.text('Food'), findsOneWidget);

    // Tap FloatingActionButton to add a category
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Verify AddCategoryScreen is opened
    expect(find.text('Add Category'), findsOneWidget);

    // Enter category name
    final nameInputFinder = find.byType(TextFormField).first;
    await tester.enterText(nameInputFinder, 'Gym');
    await tester.pumpAndSettle();

    // Tap Save button (scroll to ensure visible)
    final saveButtonFinder = find.text('Save');
    await tester.ensureVisible(saveButtonFinder);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Verify we popped back to CategoriesScreen and no failure SnackBar appears
    expect(find.text('Add Category'), findsNothing);
    expect(find.textContaining('Failed to add category'), findsNothing);

    // Verify success SnackBar alert appears
    expect(find.text('Category "Gym" added successfully.'), findsOneWidget);

    // Verify new category is loaded in the list
    expect(find.text('Gym'), findsOneWidget);

    // Verify latest added category 'Gym' is rendered on top of existing 'Food'
    final gymY = tester.getTopLeft(find.text('Gym')).dy;
    final foodY = tester.getTopLeft(find.text('Food')).dy;
    expect(gymY, lessThan(foodY), reason: 'Latest added category must appear on top');
  });
}
