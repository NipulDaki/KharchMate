import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';

/// Centralized service handling Google AdMob Banners, Rewarded Video Ads,
/// and tracking the 3-day Ad-Free pass reward state.
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
      // Preload a rewarded video ad so it is ready when user visits Settings
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

  /// Grants the user an ad-free pass for a given duration (defaults to 3 days).
  /// If the user already has an active ad-free pass, it does NOT increase or
  /// extend the days. Once the 3 days have completed and the pass expires,
  /// calling this again will grant a new 3-day pass.
  Future<bool> grantAdFreePass({
    Duration duration = const Duration(days: 3),
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

  /// Preloads a RewardedAd for the 3-day ad-free pass.
  void loadRewardedAd({
    VoidCallback? onLoaded,
    Function(LoadAdError)? onFailed,
  }) {
    if (_rewardedAd != null || _isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    try {
      RewardedAd.load(
        adUnitId: appConfig.rewardedAdUnitId,
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
            onFailed?.call(error);
            debugPrint('Rewarded ad failed to load: ${error.message}');
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      debugPrint('AdMob loadRewardedAd error: $e');
    }
  }

  /// Shows the loaded RewardedAd. When the user finishes watching, triggers
  /// `onUserEarnedReward` and automatically activates the 3-day ad-free pass.
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
        await grantAdFreePass(duration: const Duration(days: 3));
        onUserEarnedReward();
      },
    );
  }

  // ===========================================================================
  // BANNER AD CREATION
  // ===========================================================================

  /// Creates and loads a BannerAd widget configured for the Dashboard.
  BannerAd createDashboardBanner({
    required VoidCallback onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: appConfig.bannerAdUnitId,
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

  /// Dispose any active resources.
  Future<void> dispose() async {
    _expiryTimer?.cancel();
    _rewardedAd?.dispose();
    await _adFreeController.close();
  }
}
