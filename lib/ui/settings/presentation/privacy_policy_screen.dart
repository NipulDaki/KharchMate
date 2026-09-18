import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'manavinfotech8@gmail.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied to clipboard: manavinfotech8@gmail.com'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.dimen16,
            vertical: AppDimens.dimen16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.dimen20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppDimens.dimen16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.dimen5),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Last updated: September 2026',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen16),

              // Main Policy Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.dimen20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview
                    _buildSectionHeader(
                      icon: Icons.info_outline_rounded,
                      title: 'Overview',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'KharchMate is designed with privacy as a core principle. We do not require you to create an account or sign in to use the App. Profile details (such as your name or email) are stored locally on your device solely for display purposes and are never stored on our servers.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // What We Collect
                    _buildSectionHeader(
                      icon: Icons.inventory_2_outlined,
                      title: 'What We Collect',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph('The information stored in the App includes:'),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      title: 'Profile Information (Display Only)',
                      description: 'your name and email entered in the profile screen are saved locally on your device solely for display and are never stored on any server',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      title: 'A random device ID',
                      description: 'automatically generated on first launch, used solely to associate your data with your device',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      title: 'Your expense records',
                      description: 'amount, category, date, payment mode, and optional notes that you enter manually',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      title: 'Custom categories',
                      description: 'any categories you create within the App',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'We do not collect or store your bank credentials, phone number, location, contacts, or photos on any server.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Advertisements (Google AdMob)
                    _buildSectionHeader(
                      icon: Icons.ads_click_rounded,
                      title: 'Advertisements (Google AdMob)',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'To keep KharchMate free, we use (or may display) advertisements powered by Google AdMob.',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      title: 'Device & Ad Data',
                      description: 'Google AdMob may automatically receive non-personal technical device data, such as your Google Advertising ID (AAID), approximate location, and ad interaction data',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // How We Use Your Data
                    _buildSectionHeader(
                      icon: Icons.data_usage_rounded,
                      title: 'How We Use Your Data',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'Your data is used to provide core app functionality (saving, organizing, and calculating your expenses) and serving ads via Google AdMob to support maintenance. We never sell or rent your private financial data.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Data Sharing
                    _buildSectionHeader(
                      icon: Icons.share_outlined,
                      title: 'Data Sharing',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'We do not sell, share, or disclose your financial records to any third party. The only external service interacting with the app is Google AdMob for delivering advertisements.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Data Deletion
                    _buildSectionHeader(
                      icon: Icons.delete_outline_rounded,
                      title: 'Data Deletion',
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(
                            text: 'You can permanently delete all your data at any time from within the App: go to ',
                          ),
                          TextSpan(
                            text: 'Settings → Delete My Data',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text: '. This removes all your expenses, custom categories, profile details, and device ID from your device storage immediately.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Data Security
                    _buildSectionHeader(
                      icon: Icons.lock_outline_rounded,
                      title: 'Data Security',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'KharchMate operates offline and stores all your financial records and profile data locally on your device. We do not store, host, or transfer your personal or financial data on any external server.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Children
                    _buildSectionHeader(
                      icon: Icons.child_care_rounded,
                      title: 'Children',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'KharchMate does not knowingly collect personal data from children under 13. No personal information is required to use the App.',
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppColors.dividerColor),
                    const SizedBox(height: 20),

                    // Contact
                    _buildSectionHeader(
                      icon: Icons.mail_outline_rounded,
                      title: 'Contact',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'Questions about this policy? Email us at:',
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _copyEmail(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'manavinfotech8@gmail.com',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildBulletItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, right: 10),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
              children: [
                TextSpan(
                  text: '$title — ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
