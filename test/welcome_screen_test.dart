import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/ui/onboarding/presentation/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen renders 3 tutorial slides and auto-advances with timer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );
    await tester.pump();

    // Slide 1 is initially visible
    expect(find.textContaining('Take Control'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Advance 3.5 seconds to trigger auto change to Slide 2
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Smart Budgets'), findsOneWidget);

    // Advance another 3.5 seconds to trigger auto change to Slide 3
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Visual Reports'), findsOneWidget);

    // Advance another 3.5 seconds to trigger auto loop back to Slide 1
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Take Control'), findsOneWidget);

    // Tap second dot to navigate directly to Slide 2
    await tester.tap(find.byKey(const ValueKey('dot_1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Smart Budgets'), findsOneWidget);
  });
}
