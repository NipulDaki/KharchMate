import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Centralized service handling Firebase Analytics event tracking.
/// Provides strongly-typed methods for all domain analytics events
/// with safe degradation if Firebase is not yet configured.
class AnalyticsService {
  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Returns the underlying [FirebaseAnalytics] instance if available.
  FirebaseAnalytics? get analytics => _analytics;

  /// Returns a [FirebaseAnalyticsObserver] for route transition tracking in GoRouter.
  /// If Firebase is not initialized, returns `null`.
  FirebaseAnalyticsObserver? get observer {
    if (_analytics != null) {
      return FirebaseAnalyticsObserver(analytics: _analytics!);
    }
    return null;
  }

  /// Initializes Firebase and the Analytics instance safely.
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      _isInitialized = true;
      debugPrint('AnalyticsService: Firebase Analytics initialized successfully.');
    } catch (e) {
      debugPrint('AnalyticsService: Firebase not initialized or config missing: $e');
      _isInitialized = false;
      _analytics = null;
    }
  }

  /// Safe internal helper to log an event.
  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      if (_analytics != null) {
        await _analytics!.logEvent(name: name, parameters: parameters);
        debugPrint('Analytics: [$name] logged with params: $parameters');
      } else {
        debugPrint('Analytics (fallback): [$name] params: $parameters');
      }
    } catch (e) {
      debugPrint('AnalyticsService: Failed to log event $name: $e');
    }
  }

  // ===========================================================================
  // EVENT 1: App Open
  // ===========================================================================
  Future<void> logAppOpen() async {
    try {
      if (_analytics != null) {
        await _analytics!.logAppOpen();
        debugPrint('Analytics: [app_open] logged');
      }
    } catch (e) {
      debugPrint('AnalyticsService: logAppOpen error: $e');
    }
  }

  // ===========================================================================
  // EVENT 2: Screen View (manual fallback if needed)
  // ===========================================================================
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    try {
      if (_analytics != null) {
        await _analytics!.logScreenView(
          screenName: screenName,
          screenClass: screenClass ?? screenName,
        );
      }
      debugPrint('Analytics: [screen_view] screenName: $screenName');
    } catch (e) {
      debugPrint('AnalyticsService: logScreenView error: $e');
    }
  }

  // ===========================================================================
  // EVENT 3: Income Added
  // ===========================================================================
  Future<void> logIncomeAdded({
    required double amount,
    required String category,
    String? paymentMethod,
  }) async {
    await _logEvent('income_added', {
      'amount': amount,
      'category': category,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    });
  }

  // ===========================================================================
  // EVENT 4: Expense Added
  // ===========================================================================
  Future<void> logExpenseAdded({
    required double amount,
    required String category,
    String? paymentMethod,
  }) async {
    await _logEvent('expense_added', {
      'amount': amount,
      'category': category,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    });
  }

  // ===========================================================================
  // EVENT 5: Transaction Deleted
  // ===========================================================================
  Future<void> logTransactionDeleted({
    required int transactionId,
    required String type,
  }) async {
    await _logEvent('transaction_deleted', {
      'transaction_id': transactionId,
      'type': type,
    });
  }

  // ===========================================================================
  // EVENT 6: Category Created
  // ===========================================================================
  Future<void> logCategoryCreated({
    required String categoryName,
    required String type,
  }) async {
    await _logEvent('category_created', {
      'category_name': categoryName,
      'type': type,
    });
  }

  // ===========================================================================
  // EVENT 7: Category Edited
  // ===========================================================================
  Future<void> logCategoryEdited({
    required String categoryName,
    required String type,
  }) async {
    await _logEvent('category_edited', {
      'category_name': categoryName,
      'type': type,
    });
  }

  // ===========================================================================
  // EVENT 8: Search Used
  // ===========================================================================
  Future<void> logSearchUsed({
    required int queryLength,
  }) async {
    await _logEvent('search_used', {
      'query_length': queryLength,
    });
  }

  // ===========================================================================
  // EVENT 9: Rewarded Ad Clicked
  // ===========================================================================
  Future<void> logRewardedAdClicked({
    required String placement,
  }) async {
    await _logEvent('rewarded_ad_clicked', {
      'placement': placement,
    });
  }

  // ===========================================================================
  // EVENT 10: Rewarded Ad Completed
  // ===========================================================================
  Future<void> logRewardedAdCompleted({
    int durationDays = 3,
  }) async {
    await _logEvent('rewarded_ad_completed', {
      'duration_days': durationDays,
    });
  }

  // ===========================================================================
  // EVENT 11: Banner Ad Hidden (Ad-Free Pass Activated)
  // ===========================================================================
  Future<void> logBannerAdHidden({
    int durationDays = 3,
  }) async {
    await _logEvent('banner_ad_hidden', {
      'duration_days': durationDays,
    });
  }

  // ===========================================================================
  // EVENT 12: Reminder Enabled
  // ===========================================================================
  Future<void> logReminderEnabled({
    String reminderType = 'daily',
  }) async {
    await _logEvent('reminder_enabled', {
      'reminder_type': reminderType,
    });
  }

  // ===========================================================================
  // Ad Impression & Revenue Tracking (ILR - Impression-Level Ad Revenue)
  // ===========================================================================
  Future<void> logAdImpression({
    required String adFormat,
    required String adUnitName,
    required double value,
    required String currency,
    String adPlatform = 'AdMob',
  }) async {
    try {
      if (_analytics != null) {
        await _analytics!.logAdImpression(
          adPlatform: adPlatform,
          adFormat: adFormat,
          adUnitName: adUnitName,
          value: value,
          currency: currency,
        );
        debugPrint(
          'Analytics: [ad_impression] logged ($adFormat) revenue: $value $currency (unit: $adUnitName)',
        );
      } else {
        debugPrint(
          'Analytics (fallback): [ad_impression] format: $adFormat, value: $value $currency',
        );
      }
    } catch (e) {
      debugPrint('AnalyticsService: logAdImpression error: $e');
    }
  }
}
