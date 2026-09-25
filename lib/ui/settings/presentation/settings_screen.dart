import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/ad_service.dart';
import 'package:kharch_mate/services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final DatabaseService _dbService;
  AdService? _adService;
  UserProfile? _userProfile;
  // ignore: unused_field
  bool _isDarkMode = false;
  String _appVersion = '1.0';
  StreamSubscription<UserProfile>? _userProfileSubscription;
  StreamSubscription<bool>? _adFreeSubscription;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadUserProfile();
    _loadAppVersion();
    _userProfileSubscription = _dbService.onUserProfileChanged.listen((
      profile,
    ) {
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isDarkMode = profile.isDarkMode;
        });
      }
    });

    if (serviceLocator.isRegistered<AdService>()) {
      _adService = serviceLocator<AdService>();
      _adFreeSubscription = _adService!.onAdFreeChanged.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
      // Preload rewarded ad so it's ready when user wants to watch
      _adService!.loadRewardedAd();
    }
  }

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    _adFreeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _dbService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = user;
          _isDarkMode = user?.isDarkMode ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        final parts = info.version.split('.');
        final formattedVersion =
            parts.length >= 2 ? '${parts[0]}.${parts[1]}' : info.version;
        setState(() {
          _appVersion = formattedVersion;
        });
      }
    } catch (_) {}
  }

  // ignore: unused_element
  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    try {
      await _dbService.updateDarkMode(value);
      _userProfile = _userProfile?.copyWith(isDarkMode: value);
    } catch (_) {}
  }

  Future<void> _showCurrencyPicker() async {
    final currencies = [
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
      {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
      {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    ];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Select Currency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: currencies.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.dividerColor),
                    itemBuilder: (context, index) {
                      final item = currencies[index];
                      final isSelected =
                          (_userProfile?.currencyCode ?? 'INR') == item['code'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF0F4F8),
                          child: Text(
                            item['symbol']!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          '${item['name']} (${item['code']})',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () async {
                          Navigator.of(context).pop();
                          final current =
                              _userProfile ??
                              await _dbService.getUserProfile() ??
                              UserProfile.empty();
                          final updated = current.copyWith(
                            currencyCode: item['code'],
                            currencySymbol: item['symbol'],
                          );
                          final saved = await _dbService.saveUserProfile(
                            updated,
                          );
                          if (mounted) {
                            setState(() => _userProfile = saved);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out? Your recorded transactions and categories remain securely saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _dbService.deleteUser();
              if (mounted) {
                context.go(AppRoutes.welcome.path);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMyDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.expense,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Delete My Data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all your data? This will permanently remove all your transactions, budgets, custom categories, and personal profile from this device. Default categories will be preserved.\n\nThis action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _dbService.deleteMyData();
              if (mounted) {
                context.go(AppRoutes.welcome.path);
              }
            },
            child: const Text('Delete Data'),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _userProfile?.name.trim().isNotEmpty == true
        ? _userProfile!.name
        : 'Nipul Daki';
    final userEmail = _userProfile?.email?.trim().isNotEmpty == true
        ? _userProfile!.email!
        : 'nipul@example.com';
    final currencyDisplay =
        '${_userProfile?.currencyCode ?? 'INR'} (${_userProfile?.currencySymbol ?? '₹'})';

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          context.push(AppRoutes.addTransaction.path);
        },
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.dimen16,
            vertical: AppDimens.dimen16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title
              Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppDimens.dimen16),

              // User Profile Card
              _buildUserProfileCard(userName, userEmail),

              const SizedBox(height: AppDimens.dimen16),

              // 3-Day Ad-Free Pass Card
              _buildAdFreeCard(),

              const SizedBox(height: AppDimens.dimen16),

              // Settings Options Group Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // 1. Currency
                    _buildSettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Currency',
                      subtitle: currencyDisplay,
                      onTap: _showCurrencyPicker,
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 2. Categories -> Opens Categories Page!
                    _buildSettingsTile(
                      icon: Icons.grid_view_rounded,
                      title: 'Categories',
                      onTap: () {
                        context.push(AppRoutes.categories.path);
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 3. Notifications & Reminders (Commented out)
                    /*
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications & Reminders',
                      onTap: () {
                        _showInfoDialog(
                          'Notifications & Reminders',
                          'Stay informed with daily budget reminders and expense tracking alerts.',
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),
                    */

                    // 4. Dark Mode Switch (Commented out)
                    /*
                    _buildSwitchTile(
                      icon: Icons.nightlight_round_outlined,
                      title: 'Dark Mode',
                      value: _isDarkMode,
                      onChanged: _toggleDarkMode,
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),
                    */

                    // 5. Export Data (Commented out)
                    /*
                    _buildSettingsTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Export Data',
                      onTap: () {
                        _showInfoDialog(
                          'Export Data',
                          'Export your financial transactions and monthly reports as CSV or PDF documents.',
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),
                    */

                    // 7. Privacy Policy
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        context.push(AppRoutes.privacyPolicy.path);
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 8. Terms of Use
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Use',
                      onTap: () {
                        context.push(AppRoutes.termsOfUse.path);
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 7. Help & Support
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        context.push(AppRoutes.helpSupport.path);
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 8. Rate & Review Us
                    _buildSettingsTile(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFF57C00),
                      iconBackgroundColor: const Color(0xFFFFF3E0),
                      title: 'Rate & Review Us',
                      subtitle: 'Support us with a review on Google Play',
                      onTap: _showReviewDialog,
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 9. App Version
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      showChevron: false,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _appVersion,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 9. Delete My Data
                    _buildSettingsTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: AppColors.expense,
                      iconBackgroundColor: const Color(0xFFFDECEA),
                      title: 'Delete My Data',
                      titleColor: AppColors.expense,
                      showChevron: false,
                      onTap: _showDeleteMyDataDialog,
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 10. Logout
                    _buildSettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.expense,
                      iconBackgroundColor: const Color(0xFFFDECEA),
                      title: 'Logout',
                      titleColor: AppColors.expense,
                      showChevron: false,
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'KharchMate',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Version $_appVersion',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(String name, String email) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.userProfile.path);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              // Blue circle avatar with user silhouette
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E88E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdFreeCard() {
    final isAdFree = _adService?.isAdFree ?? false;
    final remainingText = _adService?.remainingAdFreeText ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdFree
              ? AppColors.income.withValues(alpha: 0.35)
              : AppColors.borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _showWatchRewardedAdDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isAdFree
                        ? AppColors.incomeLight
                        : AppColors.primaryBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAdFree
                        ? Icons.verified_rounded
                        : Icons.card_giftcard_rounded,
                    color: isAdFree ? AppColors.income : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isAdFree
                                ? 'Ad-Free Pass Active'
                                : 'Go Ad-Free for 3 Days',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAdFree ? '✨' : '🎁',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdFree
                            ? '$remainingText • Tap to extend +3 days'
                            : 'Watch a short video to remove banner ads',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isAdFree
                              ? AppColors.income
                              : AppColors.textSecondary,
                          fontWeight:
                              isAdFree ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAdFree ? AppColors.incomeLight : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdFree ? 'Active' : 'Watch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isAdFree ? AppColors.income : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWatchRewardedAdDialog() {
    final isAdFree = _adService?.isAdFree ?? false;
    final remainingText = _adService?.remainingAdFreeText ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(isAdFree ? '✨ ' : '🎁 ', style: const TextStyle(fontSize: 22)),
            Expanded(
              child: Text(
                isAdFree ? 'Extend Ad-Free Pass' : 'Unlock 3-Day Ad-Free Pass',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isAdFree
              ? 'You currently have an active ad-free pass ($remainingText).\n\nWatching another short sponsor video will add +3 full days (72 hours) to your pass!'
              : 'Watch a short sponsor video to completely remove all banner ads across KharchMate for the next 3 days (72 hours).',
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.45,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
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
              _playRewardedAd();
            },
            child: const Text('Watch Video'),
          ),
        ],
      ),
    );
  }

  void _playRewardedAd() {
    if (_adService == null) return;

    if (!_adService!.isRewardedAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Video ad is preparing. Please try again in a few moments.',
          ),
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
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🎉 Congratulations! 3 Days of Ad-Free experience activated!',
              ),
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

  void _showReviewDialog() {
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF57C00),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enjoying KharchMate?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your review on Google Play helps us improve and helps others take control of their expenses!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedRating = starIndex;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        starIndex <= selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF57C00),
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchPlayStoreReview();
                    },
                    icon: const Icon(Icons.rate_review_rounded, size: 18),
                    label: const Text(
                      'Rate on Google Play',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchPlayStoreReview() async {
    const packageName = 'com.nipul.kharchmate';
    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Play Store.'),
            ),
          );
        }
      }
    }
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? titleColor,
    bool showChevron = true,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? const Color(0xFFF0F4F8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppColors.white,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, "Home", false, () {
              context.go(AppRoutes.dashboard.path);
            }),
            _buildNavItem(
              Icons.receipt_long_rounded,
              "Transactions",
              false,
              () {
                context.go(AppRoutes.transaction.path);
              },
            ),
            const SizedBox(width: 48), // FAB center space
            _buildNavItem(Icons.bar_chart_rounded, "Reports", false, () {
              context.go(AppRoutes.report.path);
            }),
            _buildNavItem(Icons.settings_rounded, "Settings", true, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = isSelected
        ? AppColors.bottomNavSelected
        : AppColors.bottomNavUnselected;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
