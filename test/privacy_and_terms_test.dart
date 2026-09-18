import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/ui/settings/presentation/help_support_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/privacy_policy_screen.dart';
import 'package:kharch_mate/ui/settings/presentation/terms_screen.dart';

void main() {
  group('PrivacyPolicyScreen Tests', () {
    testWidgets('renders all privacy policy sections and content correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header
      expect(find.text('Privacy Policy'), findsNWidgets(2)); // AppBar + Header card
      expect(find.text('Last updated: September 2026'), findsOneWidget);

      // Check Sections
      expect(find.text('Overview'), findsOneWidget);
      expect(
        find.textContaining('KharchMate is designed with privacy as a core principle'),
        findsOneWidget,
      );

      expect(find.text('What We Collect'), findsOneWidget);
      expect(find.textContaining('The information stored in the App includes:'), findsOneWidget);
      expect(find.textContaining('Profile Information', findRichText: true), findsOneWidget);
      expect(find.textContaining('A random device ID', findRichText: true), findsOneWidget);
      expect(find.textContaining('Your expense records', findRichText: true), findsOneWidget);
      expect(find.textContaining('Custom categories', findRichText: true), findsOneWidget);
      expect(
        find.textContaining('We do not collect or store your bank credentials'),
        findsOneWidget,
      );

      // Scroll down to check further sections
      await tester.scrollUntilVisible(find.text('Contact'), 100);
      await tester.pumpAndSettle();

      expect(find.text('Advertisements (Google AdMob)'), findsOneWidget);
      expect(find.text('How We Use Your Data'), findsOneWidget);
      expect(find.text('Data Sharing'), findsOneWidget);
      expect(find.text('Data Deletion'), findsOneWidget);
      expect(find.text('Data Security'), findsOneWidget);
      expect(find.text('Children'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('manavinfotech8@gmail.com'), findsOneWidget);
    });

    testWidgets('tapping email copies email and shows snackbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrivacyPolicyScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('manavinfotech8@gmail.com'), 100);
      await tester.pumpAndSettle();

      await tester.tap(find.text('manavinfotech8@gmail.com'));
      await tester.pump();

      expect(find.textContaining('Email copied to clipboard'), findsOneWidget);
    });
  });

  group('TermsScreen Tests', () {
    testWidgets('renders all terms of use sections and content correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header
      expect(find.text('Terms of Use'), findsNWidgets(2)); // AppBar + Header card
      expect(find.text('Last updated: September 2026'), findsOneWidget);

      // Check Sections
      expect(find.text('Acceptance'), findsOneWidget);
      expect(
        find.textContaining('By downloading or using KharchMate'),
        findsOneWidget,
      );

      expect(find.text('Use of the App'), findsOneWidget);
      expect(
        find.textContaining('Attempt to reverse-engineer, decompile, or tamper'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Use the App in any way that violates applicable laws'),
        findsOneWidget,
      );

      // Scroll down
      await tester.scrollUntilVisible(find.text('Contact'), 100);
      await tester.pumpAndSettle();

      expect(find.text('Advertisements'), findsOneWidget);
      expect(find.text('Your Data'), findsOneWidget);
      expect(find.text('Data Loss'), findsOneWidget);
      expect(find.text('No Warranties'), findsOneWidget);
      expect(find.text('Limitation of Liability'), findsOneWidget);
      expect(find.text('Changes to These Terms'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('manavinfotech8@gmail.com'), findsOneWidget);
    });

    testWidgets('tapping email copies email and shows snackbar in TermsScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TermsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('manavinfotech8@gmail.com'), 100);
      await tester.pumpAndSettle();

      await tester.tap(find.text('manavinfotech8@gmail.com'));
      await tester.pump();

      expect(find.textContaining('Email copied to clipboard'), findsOneWidget);
    });
  });

  group('HelpSupportScreen Tests', () {
    testWidgets('renders all FAQ questions and contact card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Support & FAQs'), findsOneWidget);
      expect(
        find.text("We're here to help with any issues or questions about KharchMate."),
        findsOneWidget,
      );

      // Check Section
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('How do I add a new expense or income?'), findsOneWidget);
      expect(find.text('How do I edit or delete a transaction?'), findsOneWidget);
      expect(find.text('How do I create and manage custom categories?'), findsOneWidget);
      expect(find.text('Does KharchMate work offline without internet?'), findsOneWidget);
      expect(find.text('Do I need to sign up or create an account?'), findsOneWidget);

      // Scroll down to check further questions and contact card
      await tester.scrollUntilVisible(find.text('Contact Us'), 100);
      await tester.pumpAndSettle();

      expect(find.text('How do I change my currency?'), findsOneWidget);
      expect(find.text('Where can I view my spending reports and trends?'), findsOneWidget);
      expect(find.text('What happens if I uninstall the app or clear app data?'), findsOneWidget);
      expect(find.text('Is my financial data private and secure?'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('manavinfotech8@gmail.com'), findsOneWidget);
    });

    testWidgets('tapping email copies email and shows snackbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HelpSupportScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('manavinfotech8@gmail.com'), 100);
      await tester.pumpAndSettle();

      await tester.tap(find.text('manavinfotech8@gmail.com'));
      await tester.pump();

      expect(find.textContaining('Email copied to clipboard'), findsOneWidget);
    });
  });
}
