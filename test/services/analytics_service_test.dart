import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/services/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnalyticsService analyticsService;

  setUp(() {
    analyticsService = AnalyticsService();
  });

  test('AnalyticsService degrades gracefully when Firebase is not initialized', () async {
    expect(analyticsService.isInitialized, isFalse);
    expect(analyticsService.analytics, isNull);
    expect(analyticsService.observer, isNull);

    // Calling logging methods should not throw any exception
    await expectLater(analyticsService.logAppOpen(), completes);
    await expectLater(
      analyticsService.logScreenView(screenName: 'dashboard'),
      completes,
    );
    await expectLater(
      analyticsService.logIncomeAdded(
        amount: 5000,
        category: 'Salary',
        paymentMethod: 'Bank Transfer',
      ),
      completes,
    );
    await expectLater(
      analyticsService.logExpenseAdded(
        amount: 250,
        category: 'Dining',
        paymentMethod: 'UPI',
      ),
      completes,
    );
    await expectLater(
      analyticsService.logTransactionDeleted(
        transactionId: 42,
        type: 'expense',
      ),
      completes,
    );
    await expectLater(
      analyticsService.logCategoryCreated(
        categoryName: 'Freelance',
        type: 'income',
      ),
      completes,
    );
    await expectLater(
      analyticsService.logCategoryEdited(
        categoryName: 'Groceries',
        type: 'expense',
      ),
      completes,
    );
    await expectLater(
      analyticsService.logSearchUsed(queryLength: 6),
      completes,
    );
    await expectLater(
      analyticsService.logRewardedAdClicked(placement: 'dashboard'),
      completes,
    );
    await expectLater(
      analyticsService.logRewardedAdCompleted(durationDays: 3),
      completes,
    );
    await expectLater(
      analyticsService.logBannerAdHidden(durationDays: 3),
      completes,
    );
    await expectLater(
      analyticsService.logReminderEnabled(reminderType: 'daily'),
      completes,
    );
    await expectLater(
      analyticsService.logAdImpression(
        adFormat: 'Banner',
        adUnitName: 'ca-app-pub-test',
        value: 0.015,
        currency: 'USD',
      ),
      completes,
    );
  });
}
