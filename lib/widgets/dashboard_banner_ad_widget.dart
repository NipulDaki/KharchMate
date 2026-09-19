import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/ad_service.dart';

/// Dashboard Inline Banner Ad Widget.
///
/// Placed above the Pie Chart. Automatically collapses to `SizedBox.shrink()`
/// if the user has an active 3-day ad-free pass or if the ad fails to load.
class DashboardBannerAdWidget extends StatefulWidget {
  const DashboardBannerAdWidget({super.key});

  @override
  State<DashboardBannerAdWidget> createState() => _DashboardBannerAdWidgetState();
}

class _DashboardBannerAdWidgetState extends State<DashboardBannerAdWidget> {
  AdService? _adService;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  StreamSubscription<bool>? _adFreeSubscription;

  @override
  void initState() {
    super.initState();
    if (serviceLocator.isRegistered<AdService>()) {
      _adService = serviceLocator<AdService>();

      // Listen for ad-free status changes
      _adFreeSubscription = _adService!.onAdFreeChanged.listen((isAdFree) {
        if (mounted) {
          if (isAdFree) {
            _disposeBanner();
          } else if (_bannerAd == null) {
            _loadBanner();
          }
          setState(() {});
        }
      });

      if (!_adService!.isAdFree) {
        _loadBanner();
      }
    }
  }

  void _loadBanner() {
    if (_adService == null) return;
    try {
      _bannerAd = _adService!.createDashboardBanner(
        onAdLoaded: () {
          if (mounted) {
            setState(() => _isBannerLoaded = true);
          }
        },
        onAdFailedToLoad: (error) {
          if (mounted) {
            setState(() {
              _isBannerLoaded = false;
              _bannerAd = null;
            });
          }
        },
      );
    } catch (_) {
      _isBannerLoaded = false;
      _bannerAd = null;
    }
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  @override
  void dispose() {
    _adFreeSubscription?.cancel();
    _disposeBanner();
    super.dispose();
  }

  void _showRewardedAdPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🎁 ', style: TextStyle(fontSize: 20)),
            Text(
              'Remove Ads for 3 Days',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Watch a short sponsor video to enjoy a 100% ad-free experience across KharchMate for the next 72 hours.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _watchVideo();
            },
            child: const Text('Watch Video'),
          ),
        ],
      ),
    );
  }

  void _watchVideo() {
    if (_adService == null) return;

    if (!_adService!.isRewardedAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video ad is preparing. Please try again in a few seconds.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      _adService!.loadRewardedAd();
      return;
    }

    _adService!.showRewardedAd(
      onUserEarnedReward: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 3-Day Ad-Free Pass unlocked! Banner removed.'),
              backgroundColor: AppColors.income,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      onFailedToShow: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not play video: ${error.message}'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If user has an active ad-free pass or ad is not loaded, completely collapse
    if (_adService == null || _adService!.isAdFree || !_isBannerLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.dimen16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Ad badge + "Remove Ads for 3 Days" shortcut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _showRewardedAdPrompt,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Remove for 3 days 🎁',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Actual Banner Ad Widget
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ],
      ),
    );
  }
}
