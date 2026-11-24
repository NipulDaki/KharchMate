import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/extension/theme_extension.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'supportnexoralab@gmail.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied to clipboard: supportnexoralab@gmail.com'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: context.colors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms of Use',
          style: theme.textTheme.titleLarge?.copyWith(
            color: context.colors.textPrimary,
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
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.colors.primaryBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: context.colors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppDimens.dimen16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Use',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.dimen5),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: context.colors.textHint,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Last updated: September 2026',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
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

              // Main Terms Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.dimen20),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Acceptance
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Acceptance',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'By downloading or using KharchMate ("the App"), you agree to these Terms of Use. If you do not agree, please do not use the App.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Use of the App
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.touch_app_outlined,
                      title: 'Use of the App',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'The App is provided for personal, non-commercial use to help you track your own expenses. You agree not to:',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletItem(
                      context,
                      'Attempt to reverse-engineer, decompile, or tamper with the App',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      context,
                      'Use the App in any way that violates applicable laws or regulations',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      context,
                      'Submit false, misleading, or harmful content through the App',
                    ),
                    const SizedBox(height: 6),
                    _buildBulletItem(
                      context,
                      'Use automated tools, bots, or scripts to disrupt or tamper with the App',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Advertisements
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.ads_click_rounded,
                      title: 'Advertisements',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'KharchMate is free to use and supported by third-party advertising via Google AdMob. By using the app, you agree to the display of advertisements. We do not endorse any third-party products or services shown in ads.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Your Data
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.security_rounded,
                      title: 'Your Data',
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: context.colors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'You own the expense data you enter. We store it solely to provide the App\'s functionality. See our ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(AppRoutes.privacyPolicy.path);
                              },
                          ),
                          const TextSpan(
                            text:
                                ' for full details on how your data is handled.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Data Loss
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      title: 'Data Loss',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'KharchMate stores your records on your device without requiring passwords or cloud accounts. If you uninstall the app or clear its device data, your records will be permanently lost as we do not provide backup or recovery services at this time. We are not liable for any loss of data.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // No Warranties
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.gavel_rounded,
                      title: 'No Warranties',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'The App is provided "as is" without warranties of any kind. We do not warrant that the App will be error-free, accurate, or suitable for any particular purpose.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Limitation of Liability
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.policy_outlined,
                      title: 'Limitation of Liability',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'To the maximum extent permitted by law, we are not liable for any indirect, incidental, or consequential damages arising from your use of the App.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Changes to These Terms
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.update_rounded,
                      title: 'Changes to These Terms',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the updated Terms.',
                    ),

                    const SizedBox(height: 20),
                    Divider(height: 1, color: context.colors.divider),
                    const SizedBox(height: 20),

                    // Contact
                    _buildSectionHeader(
                      context: context,
                      icon: Icons.mail_outline_rounded,
                      title: 'Contact',
                    ),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      context,
                      'Questions? Email us at:',
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
                          color: context.colors.primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colors.primaryLight.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'supportnexoralab@gmail.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: context.colors.primary,
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

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.elevatedSurface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: context.colors.textSecondary,
      ),
    );
  }

  Widget _buildBulletItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, right: 10),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: context.colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
