import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/widgets/app_loader.dart';

void main() {
  testWidgets('AppLoader renders with fixed width and does not stretch to full width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: AppLoader(loadingText: 'Loading dashboard...'),
          ),
        ),
      ),
    );

    // Find the decorated card container
    final containerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null,
    );

    expect(containerFinder, findsOneWidget);

    final size = tester.getSize(containerFinder);
    expect(size.width, equals(100.0));
  });

  testWidgets('AppLoader respects custom fixed width when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoader(
            loadingText: 'Loading...',
            width: 120,
          ),
        ),
      ),
    );

    final containerFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null,
    );

    expect(containerFinder, findsOneWidget);

    final size = tester.getSize(containerFinder);
    expect(size.width, equals(120.0));
  });
}
