import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/categories/presentation/categories_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/help_support_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/privacy_policy_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/settings_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/terms_screen.dart';
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

    // Save initial user profile
    await databaseService.saveUserProfile(
      UserProfile(
        name: 'Nipul Daki',
        email: 'nipul@example.com',
        currencyCode: 'INR',
        currencySymbol: '₹',
        isDarkMode: false,
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

  testWidgets('SettingsScreen displays all mockup settings items and user profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Verify Title & Profile
    expect(find.text('Settings'), findsNWidgets(2)); // Title and bottom nav
    expect(find.text('Nipul Daki'), findsOneWidget);
    expect(find.text('nipul@example.com'), findsOneWidget);

    // Verify settings options
    expect(find.text('Currency'), findsOneWidget);
    expect(find.textContaining('INR (₹)'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    // Commented out or removed options
    expect(find.text('Notifications & Reminders'), findsNothing);
    expect(find.text('Dark Mode'), findsNothing);
    expect(find.text('Export Data'), findsNothing);
    expect(find.text('Privacy & Security'), findsNothing);
    // Active options
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Delete My Data'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Tapping Categories in Settings opens the Categories screen', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.settings.path,
      routes: [
        GoRoute(
          path: AppRoutes.settings.path,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.categories.path,
          builder: (context, state) => const CategoriesScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Tap on Categories item
    await tester.tap(find.text('Categories'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Verify CategoriesScreen is now visible with Predefined categories
    expect(find.text('Expense'), findsAtLeastNWidgets(1));
    expect(find.text('Income'), findsAtLeastNWidgets(1));
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  test('DatabaseService updates dark mode preference', () async {
    await databaseService.updateDarkMode(true);
    final user = await databaseService.getUserProfile();
    expect(user?.isDarkMode, isTrue);
  });

  testWidgets('Tapping Currency opens currency selector bottom sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    await tester.tap(find.text('Currency'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Select Currency'), findsOneWidget);
    expect(find.textContaining('US Dollar (USD)'), findsOneWidget);
    expect(find.textContaining('Euro (EUR)'), findsOneWidget);

    // Dismiss sheet
    Navigator.of(tester.element(find.text('Select Currency'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Tapping Privacy Policy in Settings opens PrivacyPolicyScreen', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.settings.path,
      routes: [
        GoRoute(
          path: AppRoutes.settings.path,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy.path,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Scroll and Tap on Privacy Policy
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    // Verify PrivacyPolicyScreen content is displayed
    expect(find.text('What We Collect'), findsOneWidget);
    expect(find.text('How We Use Your Data'), findsOneWidget);
    expect(find.textContaining('manavinfotech8@gmail.com'), findsOneWidget);
  });

  testWidgets('Tapping Terms of Use in Settings opens TermsScreen', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.settings.path,
      routes: [
        GoRoute(
          path: AppRoutes.settings.path,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.termsOfUse.path,
          builder: (context, state) => const TermsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Scroll and Tap on Terms of Use
    await tester.ensureVisible(find.text('Terms of Use'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms of Use'));
    await tester.pumpAndSettle();

    // Verify TermsScreen content is displayed
    expect(find.text('Acceptance'), findsOneWidget);
    expect(find.text('Use of the App'), findsOneWidget);
    expect(find.textContaining('manavinfotech8@gmail.com'), findsOneWidget);
  });

  testWidgets('Tapping Help & Support in Settings opens HelpSupportScreen', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoutes.settings.path,
      routes: [
        GoRoute(
          path: AppRoutes.settings.path,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.helpSupport.path,
          builder: (context, state) => const HelpSupportScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Scroll and Tap on Help & Support
    await tester.ensureVisible(find.text('Help & Support'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();

    // Verify HelpSupportScreen content is displayed
    expect(find.text('Support & FAQs'), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('How do I add a new expense or income?'), findsOneWidget);
    expect(find.textContaining('manavinfotech8@gmail.com'), findsOneWidget);
  });

  test('DatabaseService.deleteMyData removes transactions, budgets, custom categories, and user while preserving default categories', () async {
    // Insert a custom category
    final customCat = await databaseService.insertCategory(
      CategoryModel(
        name: 'Custom Gym',
        type: CategoryType.expense,
        icon: 'fitness_center',
        color: '#FF0000',
        isDefault: false,
        createdAt: DateTime.now(),
      ),
    );

    // Insert a transaction
    await databaseService.insertTransaction(
      TransactionItem(
        amount: 500,
        type: TransactionType.expense,
        categoryId: customCat.id!,
        categoryName: 'Custom Gym',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Verify before deletion
    expect(await databaseService.hasUser(), isTrue);
    final allCatsBefore = await databaseService.getAllCategories();
    expect(allCatsBefore.any((c) => c.name == 'Custom Gym'), isTrue);
    final txsBefore = await databaseService.getTransactions();
    expect(txsBefore.length, 1);

    // Call deleteMyData
    await databaseService.deleteMyData();

    // Verify after deletion
    expect(await databaseService.hasUser(), isFalse);
    final allCatsAfter = await databaseService.getAllCategories();
    expect(allCatsAfter.any((c) => c.name == 'Custom Gym'), isFalse);
    expect(allCatsAfter.any((c) => c.name == 'Food' && c.isDefault), isTrue);
    expect(allCatsAfter.any((c) => c.name == 'Rent' && c.isDefault), isTrue);
    expect(allCatsAfter.any((c) => c.name == 'Salary' && c.isDefault), isTrue);
    final txsAfter = await databaseService.getTransactions();
    expect(txsAfter, isEmpty);
  });
}
