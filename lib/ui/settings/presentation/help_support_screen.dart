import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
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
                        Icons.help_outline_rounded,
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
                            'Support & FAQs',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimens.dimen5),
                          const Text(
                            "We're here to help with any issues or questions about KharchMate.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen24),

              // Section Title: Frequently Asked Questions
              _buildSectionTitle(
                icon: Icons.question_answer_outlined,
                title: 'Frequently Asked Questions',
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 1: Add Expense / Income
              _buildFaqTile(
                context: context,
                icon: Icons.add_circle_outline_rounded,
                question: 'How do I add a new expense or income?',
                initiallyExpanded: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(1, 'Tap the "+" button located in the center of the bottom navigation bar.'),
                    _buildStep(2, 'Select Expense or Income at the top toggle.'),
                    _buildStep(3, 'Enter the Amount in your chosen currency.'),
                    _buildStep(4, 'Choose a Category (e.g., Food, Shopping, Salary, Bills).'),
                    _buildStep(5, 'Select your Payment Mode (Cash, UPI, Card, Net Banking).'),
                    _buildStep(6, 'Pick the Date & Time (defaults to today) and optionally add a Note.'),
                    _buildStep(7, 'Tap "Save Transaction". Your records and dashboard update instantly!'),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 2: Edit or Delete Transaction
              _buildFaqTile(
                context: context,
                icon: Icons.edit_note_rounded,
                question: 'How do I edit or delete a transaction?',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editing a Transaction:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStep(1, 'Go to the Transactions tab from the bottom navigation (or tap any transaction under Recent Transactions on the Dashboard).'),
                    _buildStep(2, 'Tap the transaction to open the Transaction Details screen.'),
                    _buildStep(3, 'Tap the "Edit" button at the bottom.'),
                    _buildStep(4, 'Update any field (amount, category, payment mode, date, or note) and tap "Save Changes".'),
                    const SizedBox(height: 10),
                    const Text(
                      'Deleting a Transaction:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStep(1, 'Open the Transaction Details screen.'),
                    _buildStep(2, 'Tap the "Delete Transaction" button at the bottom.'),
                    _buildStep(3, 'Confirm in the prompt to permanently remove it from your records.'),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 3: Custom Category
              _buildFaqTile(
                context: context,
                icon: Icons.category_outlined,
                question: 'How do I create and manage custom categories?',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You can manage categories in two ways:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('From Settings', 'Go to Settings → Categories, switch between Expense and Income tabs, and tap "+ Add Category".'),
                    _buildBullet('While Adding a Transaction', 'Scroll to the end of the categories list and tap the "+ Add" chip.'),
                    const SizedBox(height: 8),
                    _buildParagraph(
                      'Customize your category with a unique name, an icon from the icon selector, and a custom color. You can edit or delete your custom categories anytime from the Categories page.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 4: Offline Storage
              _buildFaqTile(
                context: context,
                icon: Icons.wifi_off_rounded,
                question: 'Does KharchMate work offline without internet?',
                content: _buildParagraph(
                  'Yes! KharchMate is built completely offline-first. All your expenses, incomes, categories, and settings are stored locally on your device in a secure SQLite database. No internet or cellular data is ever required to manage your finances.',
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 5: Account & Sign Up
              _buildFaqTile(
                context: context,
                icon: Icons.person_outline_rounded,
                question: 'Do I need to sign up or create an account?',
                content: _buildParagraph(
                  'No. KharchMate works immediately with zero signup, passwords, or cloud accounts. Your name and email address are kept strictly on your local device solely for personalized display.',
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 6: Change Currency
              _buildFaqTile(
                context: context,
                icon: Icons.currency_exchange_rounded,
                question: 'How do I change my currency?',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep(1, 'Go to the Settings tab in the bottom navigation.'),
                    _buildStep(2, 'Tap on Currency.'),
                    _buildStep(3, 'Select your preferred currency (INR ₹, USD \$, EUR €, GBP £, CAD C\$, AUD A\$, AED د.إ, JPY ¥).'),
                    _buildStep(4, 'All amounts, balances, and reports across KharchMate immediately update to the new currency symbol.'),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 7: Reports & Analytics
              _buildFaqTile(
                context: context,
                icon: Icons.insert_chart_outlined_rounded,
                question: 'Where can I view my spending reports and trends?',
                content: _buildParagraph(
                  'Tap the "Reports" tab in the bottom navigation bar. You will find interactive category breakdown charts, top spending categories ranked with percentages, income vs. expense balance, and monthly financial summaries.',
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 8: Uninstall / Data Loss
              _buildFaqTile(
                context: context,
                icon: Icons.delete_sweep_outlined,
                question: 'What happens if I uninstall the app or clear app data?',
                content: _buildParagraph(
                  'Because KharchMate stores all data 100% locally on your physical device for complete privacy, deleting or uninstalling the app or clearing its storage in your device settings will permanently erase your local database. Please keep note of your key summaries before resetting your device.',
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // FAQ Item 9: Privacy & Security
              _buildFaqTile(
                context: context,
                icon: Icons.lock_outline_rounded,
                question: 'Is my financial data private and secure?',
                content: _buildParagraph(
                  'Yes, absolutely. Your records are never uploaded or synced to external servers, nor are they sold to any third party. Your financial data belongs exclusively to you on your device. Please read our Privacy Policy in Settings for full details.',
                ),
              ),

              const SizedBox(height: AppDimens.dimen24),

              // Contact Us Card
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
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppDimens.dimen12),
                        const Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.dimen12),
                    const Text(
                      'Have questions, feedback, or need help with a bug? Reach out to our support team directly:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen16),
                    InkWell(
                      onTap: () => _copyEmail(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.dimen14,
                          vertical: AppDimens.dimen12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'manavinfotech8@gmail.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen10),
                    const Text(
                      'We typically respond within 24–48 hours.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
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

  Widget _buildSectionTitle({required IconData icon, required String title}) {
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

  Widget _buildFaqTile({
    required BuildContext context,
    required IconData icon,
    required String question,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.dimen16,
            vertical: 4.0,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 1, color: AppColors.dividerColor),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int stepNumber, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$stepNumber',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
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
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
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
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}
