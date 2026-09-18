import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/ui/onboarding/presentation/user_name_screen.dart';
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

  testWidgets('UserNameScreen renders full name and email fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserNameScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Full Name'), findsOneWidget);
    expect(find.text('Your Email Address'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('UserNameScreen validates empty name and email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserNameScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Get Started without filling fields
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name to continue'), findsOneWidget);
    expect(find.text('Email cannot be empty'), findsOneWidget);
  });

  testWidgets('UserNameScreen validates invalid email format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UserNameScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(
      find.byType(TextFormField).first,
      'Nipul Daki',
    );
    // Enter invalid email
    await tester.enterText(
      find.byType(TextFormField).last,
      'invalid-email',
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
