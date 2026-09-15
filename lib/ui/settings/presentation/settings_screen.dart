import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final DatabaseService _dbService;
  UserProfile? _userProfile;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadUserProfile();
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
                          if (_userProfile != null) {
                            final updated = _userProfile!.copyWith(
                              currencyCode: item['code'],
                              currencySymbol: item['symbol'],
                            );
                            await _dbService.saveUserProfile(updated);
                            setState(() => _userProfile = updated);
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

                    // 3. Notifications & Reminders
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

                    // 4. Dark Mode Switch
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

                    // 5. Export Data
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

                    // 6. Privacy & Security
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () {
                        _showInfoDialog(
                          'Privacy & Security',
                          'KharchMate keeps all your financial records locally on your device with offline SQLite storage.',
                        );
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
                        _showInfoDialog(
                          'Help & Support',
                          'Need help with KharchMate? Reach out to support@kharchmate.app for feedback and queries.',
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.dividerColor,
                    ),

                    // 8. Logout
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

              const SizedBox(height: AppDimens.dimen40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            child: const Icon(Icons.person, color: AppColors.white, size: 32),
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
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? titleColor,
    bool showChevron = true,
    required VoidCallback onTap,
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
            if (showChevron)
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
                context.push(AppRoutes.transaction.path);
              },
            ),
            const SizedBox(width: 48), // FAB center space
            _buildNavItem(Icons.bar_chart_rounded, "Reports", false, () {
              context.push(AppRoutes.report.path);
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
