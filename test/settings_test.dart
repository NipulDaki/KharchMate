import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/categories/presentation/categories_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/settings_screen.dart';
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

    // Verify All 8 settings options
    expect(find.text('Currency'), findsOneWidget);
    expect(find.textContaining('INR (₹)'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Notifications & Reminders'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Export Data'), findsOneWidget);
    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
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
}
