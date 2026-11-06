import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

/// Centralized service handling Google AdMob Banners, Rewarded Video Ads,
/// and tracking the 1-day Ad-Free pass reward state.
class AdService {
  static const String _adFreeUntilKey = 'ad_free_until_timestamp';

  final SecureStorageService storageService;
  final AppConfig appConfig;
  DateTime? _adFreeUntil;
  Timer? _expiryTimer;
  final StreamController<bool> _adFreeController =
      StreamController<bool>.broadcast();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;
  DateTime? _appOpenLoadTime;
  bool _isShowingAppOpenAd = false;
  Completer<bool>? _appOpenCompleter;

  AdService({required this.storageService, AppConfig? appConfig})
    : appConfig = appConfig ?? AppConfig.current;

  /// Stream that emits whenever the ad-free status changes.
  Stream<bool> get onAdFreeChanged => _adFreeController.stream;

  /// Expiration timestamp for the current ad-free period.
  DateTime? get adFreeUntil => _adFreeUntil;

  /// Returns `true` if the user currently has an active ad-free pass.
  bool get isAdFree {
    if (_adFreeUntil == null) return false;
    return DateTime.now().isBefore(_adFreeUntil!);
  }

  /// Human-readable remaining time for the ad-free pass (e.g., "2d 18h remaining").
  String get remainingAdFreeText {
    if (!isAdFree) return 'Inactive';
    final remaining = _adFreeUntil!.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} $hours hr${hours > 1 ? 's' : ''} left';
    } else if (hours > 0) {
      final mins = remaining.inMinutes % 60;
      return '$hours hr${hours > 1 ? 's' : ''} $mins min left';
    } else {
      final mins = remaining.inMinutes;
      return '$mins min left';
    }
  }

  /// Initialize AdMob SDK and restore stored ad-free status.
  Future<void> init() async {
    // 1. Initialize Google Mobile Ads SDK safely
    try {
      await MobileAds.instance.initialize();

      // Configure test device IDs so test ads are allowed on physical testing devices
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [
            'BC529CCD929EBB70806A5186108A7998', // Physical testing device
          ],
        ),
      );

      // Preload App Open ad and Rewarded Video ad
      loadAppOpenAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob SDK initialization warning: $e');
    }

    // 2. Restore saved ad-free expiration timestamp
    await _loadAdFreeStatus();
  }

  /// Reload stored ad-free status from secure storage.
  Future<void> _loadAdFreeStatus() async {
    try {
      final savedIso = await storageService.getString(_adFreeUntilKey);
      if (savedIso != null && savedIso.isNotEmpty) {
        final parsed = DateTime.tryParse(savedIso);
        if (parsed != null && DateTime.now().isBefore(parsed)) {
          _adFreeUntil = parsed;
          _scheduleExpiryTimer();
        } else {
          _adFreeUntil = null;
        }
      }
    } catch (_) {
      _adFreeUntil = null;
    }
    _notifyAdFreeChanged();
  }

  void _scheduleExpiryTimer() {
    _expiryTimer?.cancel();
    if (_adFreeUntil != null && isAdFree) {
      final remaining = _adFreeUntil!.difference(DateTime.now());
      _expiryTimer = Timer(remaining, () {
        _notifyAdFreeChanged();
      });
    }
  }

  /// Grants the user an ad-free pass for a given duration (defaults to 1 day).
  /// If the user already has an active ad-free pass, it does NOT increase or
  /// extend the days. Once the 1 day has completed and the pass expires,
  /// calling this again will grant a new 1-day pass.
  Future<bool> grantAdFreePass({
    Duration duration = const Duration(days: 1),
  }) async {
    if (isAdFree) {
      // Pass is already active; do not increase the days.
      return false;
    }

    final newExpiry = DateTime.now().add(duration);
    _adFreeUntil = newExpiry;

    try {
      await storageService.writeSecureData(
        _adFreeUntilKey,
        newExpiry.toIso8601String(),
      );
    } catch (_) {}

    _scheduleExpiryTimer();
    _notifyAdFreeChanged();
    return true;
  }

  void _notifyAdFreeChanged() {
    if (!_adFreeController.isClosed) {
      _adFreeController.add(isAdFree);
    }
  }

  // ===========================================================================
  // REWARDED VIDEO AD METHODS
  // ===========================================================================

  /// Whether a rewarded video ad is loaded and ready to display.
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Whether a rewarded ad is currently in progress of loading.
  bool get isRewardedAdLoading => _isRewardedAdLoading;

  /// Preloads a RewardedAd for the 1-day ad-free pass.
  void loadRewardedAd({
    String? overrideAdUnitId,
    VoidCallback? onLoaded,
    Function(LoadAdError)? onFailed,
  }) {
    if (_rewardedAd != null || _isRewardedAdLoading) return;

    final adUnitId = overrideAdUnitId ?? appConfig.rewardedAdUnitId;
    _isRewardedAdLoading = true;
    try {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            onLoaded?.call();
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isRewardedAdLoading = false;
            debugPrint('Rewarded ad ($adUnitId) failed to load: ${error.message}');
            if (adUnitId != appConfig.testRewardedAdUnitId) {
              loadRewardedAd(
                overrideAdUnitId: appConfig.testRewardedAdUnitId,
                onLoaded: onLoaded,
                onFailed: onFailed,
              );
              return;
            }
            onFailed?.call(error);
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      debugPrint('AdMob loadRewardedAd error: $e');
    }
  }

  /// Shows the loaded RewardedAd. When the user finishes watching, triggers
  /// `onUserEarnedReward` and automatically activates the 1-day ad-free pass.
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onDismissed,
    Function(AdError)? onFailedToShow,
  }) {
    if (_rewardedAd == null) {
      // If ad was not ready, try loading one for next time
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onFailedToShow?.call(error);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        await grantAdFreePass(duration: const Duration(days: 1));
        onUserEarnedReward();
      },
    );
  }

  // ===========================================================================
  // BANNER AD CREATION
  // ===========================================================================

  /// Creates and loads a BannerAd widget configured for the Dashboard.
  BannerAd createDashboardBanner({
    String? adUnitId,
    required VoidCallback onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: adUnitId ?? appConfig.bannerAdUnitId,
      size: AdSize.banner, // 320x50 standard banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    )..load();
  }

  // ===========================================================================
  // APP OPEN AD METHODS
  // ===========================================================================

  bool _hasShownAppOpenAdOnLaunch = false;

  /// Whether an App Open ad is loaded, not expired (< 4 hrs), and ready to display.
  bool get isAppOpenAdAvailable {
    return !isAdFree &&
        _appOpenAd != null &&
        _appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);
  }

  /// Whether an App Open ad is currently loading.
  bool get isAppOpenAdLoading => _isAppOpenAdLoading;

  /// Whether an App Open ad is currently being shown on screen.
  bool get isShowingAppOpenAd => _isShowingAppOpenAd;

  /// Resets the launch ad flag (e.g., if needed).
  void resetAppOpenAdLaunchFlag() {
    _hasShownAppOpenAdOnLaunch = false;
  }

  /// Preloads an AppOpenAd.
  void loadAppOpenAd({
    VoidCallback? onLoaded,
    Function(LoadAdError)? onFailed,
  }) {
    if (isAdFree || isAppOpenAdAvailable || _isAppOpenAdLoading) {
      if (isAppOpenAdAvailable) onLoaded?.call();
      return;
    }

    _loadAppOpenAdInternal(
      appConfig.appOpenAdUnitId,
      onLoaded: onLoaded,
      onFailed: onFailed,
    );
  }

  void _loadAppOpenAdInternal(
    String adUnitId, {
    VoidCallback? onLoaded,
    Function(LoadAdError)? onFailed,
  }) {
    _isAppOpenAdLoading = true;
    _appOpenCompleter ??= Completer<bool>();

    debugPrint('Loading AppOpenAd with unit ID: $adUnitId');

    try {
      AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _appOpenLoadTime = DateTime.now();
            _isAppOpenAdLoading = false;
            debugPrint('AppOpenAd loaded successfully ($adUnitId).');
            if (_appOpenCompleter != null && !_appOpenCompleter!.isCompleted) {
              _appOpenCompleter!.complete(true);
            }
            onLoaded?.call();
          },
          onAdFailedToLoad: (error) {
            debugPrint(
              'AppOpenAd ($adUnitId) failed to load: ${error.message} (code: ${error.code})',
            );

            // Fallback to Google test AppOpenAd unit if configured ad unit failed (e.g. 403 or code 3)
            if (adUnitId != appConfig.testAppOpenAdUnitId) {
              debugPrint(
                'Retrying AppOpenAd with Google test unit: ${appConfig.testAppOpenAdUnitId}',
              );
              _loadAppOpenAdInternal(
                appConfig.testAppOpenAdUnitId,
                onLoaded: onLoaded,
                onFailed: onFailed,
              );
              return;
            }

            _appOpenAd = null;
            _appOpenLoadTime = null;
            _isAppOpenAdLoading = false;
            if (_appOpenCompleter != null && !_appOpenCompleter!.isCompleted) {
              _appOpenCompleter!.complete(false);
            }
            onFailed?.call(error);
          },
        ),
      );
    } catch (e) {
      _isAppOpenAdLoading = false;
      if (_appOpenCompleter != null && !_appOpenCompleter!.isCompleted) {
        _appOpenCompleter!.complete(false);
      }
      debugPrint('AdMob loadAppOpenAd exception: $e');
    }
  }

  /// Shows the loaded AppOpenAd.
  /// Calls [onComplete] when dismissed or if display fails.
  void showAppOpenAd({
    VoidCallback? onComplete,
  }) {
    if (!isAppOpenAdAvailable) {
      onComplete?.call();
      loadAppOpenAd();
      return;
    }

    _isShowingAppOpenAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        _isShowingAppOpenAd = false;
        onComplete?.call();
        loadAppOpenAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpenAd failed to show: ${error.message}');
        ad.dispose();
        _appOpenAd = null;
        _appOpenLoadTime = null;
        _isShowingAppOpenAd = false;
        onComplete?.call();
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  /// Shows the AppOpenAd when entering Dashboard on app launch.
  /// If the ad is already loaded, it displays immediately.
  /// If still loading, it waits up to [timeout] and displays upon load.
  Future<void> showAppOpenAdOnDashboard({
    Duration timeout = const Duration(seconds: 6),
    VoidCallback? onDismissed,
  }) async {
    if (isAdFree || _hasShownAppOpenAdOnLaunch) {
      return;
    }

    if (isAppOpenAdAvailable) {
      _hasShownAppOpenAdOnLaunch = true;
      showAppOpenAd(onComplete: onDismissed);
      return;
    }

    if (!_isAppOpenAdLoading) {
      loadAppOpenAd();
    }

    if (_isAppOpenAdLoading && _appOpenCompleter != null) {
      try {
        final success = await _appOpenCompleter!.future.timeout(timeout);
        if (success && isAppOpenAdAvailable) {
          _hasShownAppOpenAdOnLaunch = true;
          showAppOpenAd(onComplete: onDismissed);
        }
      } catch (e) {
        debugPrint('AppOpenAd dashboard wait timeout or error: $e');
      }
    }
  }

  /// Displays the AppOpenAd if available, or waits up to [timeout] if currently loading.
  /// Calls [onComplete] once the ad is closed, fails, or if not available.
  Future<void> showAppOpenAdWhenReady({
    required VoidCallback onComplete,
    Duration timeout = const Duration(milliseconds: 2000),
  }) async {
    if (isAdFree) {
      onComplete();
      return;
    }

    if (isAppOpenAdAvailable) {
      showAppOpenAd(onComplete: onComplete);
      return;
    }

    if (_isAppOpenAdLoading && _appOpenCompleter != null) {
      try {
        await _appOpenCompleter!.future.timeout(timeout);
      } catch (_) {
        // Timeout reached, proceed without ad
      }
    }

    if (isAppOpenAdAvailable) {
      showAppOpenAd(onComplete: onComplete);
    } else {
      onComplete();
      loadAppOpenAd();
    }
  }

  /// Dispose any active resources.
  Future<void> dispose() async {
    _expiryTimer?.cancel();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    await _adFreeController.close();
  }
}
