import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:kharch_mate/ui/onboarding/presentation/app_tutorial_screen.dart';

void main() {
  setUp(() {
    serviceLocator.reset();
    serviceLocator.registerSingleton<SecureStorageService>(SecureStorageService());
  });

  tearDown(() {
    serviceLocator.reset();
  });

  Widget createTutorialScreen({bool isFromSettings = false, int initialIndex = 0}) {
    return MaterialApp(
      home: AppTutorialScreen(
        isFromSettings: isFromSettings,
        initialIndex: initialIndex,
      ),
    );
  }

  testWidgets('Renders first page (App Tour) by default', (tester) async {
    await tester.pumpWidget(createTutorialScreen());
    await tester.pumpAndSettle();

    expect(find.text('How KharchMate Works'), findsOneWidget);
    expect(find.text('Step-by-Step Instructions'), findsOneWidget);
    expect(find.text('App Tour'), findsOneWidget);
    expect(find.text('Add Category'), findsOneWidget);
    expect(find.text('Add Income'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });

  testWidgets('Switching topics updates the content to Category Guide', (tester) async {
    await tester.pumpWidget(createTutorialScreen());
    await tester.pumpAndSettle();

    // Tap on 'Add Category' topic chip
    final categoryChip = find.text('Add Category');
    expect(categoryChip, findsOneWidget);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();

    expect(find.text('How to Add a Category'), findsOneWidget);
    expect(find.text('STEP 2 OF 6 • CATEGORIES'), findsOneWidget);
  });

  testWidgets('Switching to Add Income shows income guide', (tester) async {
    await tester.pumpWidget(createTutorialScreen(initialIndex: 2));
    await tester.pumpAndSettle();

    expect(find.text('How to Add Income'), findsOneWidget);
    expect(find.text('STEP 3 OF 6 • INCOME'), findsOneWidget);
    expect(find.textContaining('Received Amount'), findsOneWidget);
  });

  testWidgets('Switching to Add Expense shows expense guide', (tester) async {
    await tester.pumpWidget(createTutorialScreen(initialIndex: 3));
    await tester.pumpAndSettle();

    expect(find.text('How to Add Expense'), findsOneWidget);
    expect(find.text('STEP 4 OF 6 • EXPENSE'), findsOneWidget);
    expect(find.textContaining('Spent Amount'), findsOneWidget);
  });

  testWidgets('Next button advances pages smoothly', (tester) async {
    await tester.pumpWidget(createTutorialScreen());
    await tester.pumpAndSettle();

    expect(find.text('How KharchMate Works'), findsOneWidget);

    final nextButton = find.text('Next Step →');
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('How to Add a Category'), findsOneWidget);
  });
}
