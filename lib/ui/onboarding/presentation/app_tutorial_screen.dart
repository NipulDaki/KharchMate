import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/secure_storage_service.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';

/// Data model representing a structured tutorial section.
class TutorialStepData {
  final String topicBadge;
  final String title;
  final String subtitle;
  final IconData tabIcon;
  final String tabLabel;
  final List<String> steps;
  final String proTip;
  final Widget previewWidget;

  const TutorialStepData({
    required this.topicBadge,
    required this.title,
    required this.subtitle,
    required this.tabIcon,
    required this.tabLabel,
    required this.steps,
    required this.proTip,
    required this.previewWidget,
  });
}

class AppTutorialScreen extends StatefulWidget {
  final bool isFromSettings;
  final int initialIndex;

  const AppTutorialScreen({
    super.key,
    this.isFromSettings = false,
    this.initialIndex = 0,
  });

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen> {
  late final PageController _pageController;
  late int _currentPage;
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex.clamp(0, 5);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    try {
      final storage = serviceLocator<SecureStorageService>();
      await storage.setTutorialSeen(seen: true);
    } catch (_) {}

    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard.path);
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _tutorialPages.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToActiveTab(int index) {
    // Keep tab indicator visible in horizontal scroll
    if (_tabScrollController.hasClients) {
      final offset = (index * 110.0) - 40;
      _tabScrollController.animateTo(
        offset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _tutorialPages.length - 1;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, theme),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Horizontal Topic Tabs
              _buildTopicTabs(theme),

              const SizedBox(height: 8),

              // 2. Slide Content PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _tutorialPages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _scrollToActiveTab(index);
                  },
                  itemBuilder: (context, index) {
                    return _buildTutorialCard(
                      context,
                      theme,
                      _tutorialPages[index],
                    );
                  },
                ),
              ),

              // 3. Bottom Navigation & Indicators
              _buildBottomControls(theme, isLastPage),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.dashboard.path);
          }
        },
      ),
      title: Text(
        'How to Use App',
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          tooltip: 'Close Guide',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard.path);
            }
          },
        ),
        const SizedBox(width: AppDimens.dimen8),
      ],
    );
  }

  Widget _buildTopicTabs(ThemeData theme) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      child: ListView.separated(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.dimen16),
        itemCount: _tutorialPages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _currentPage == index;
          final item = _tutorialPages[index];

          return GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.tabIcon,
                    size: 16,
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.tabLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTutorialCard(
    BuildContext context,
    ThemeData theme,
    TutorialStepData data,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.dimen16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.topicBadge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
                letterSpacing: 0.6,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            data.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            data.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Visual Preview
          data.previewWidget,

          const SizedBox(height: 18),

          // Step-by-Step Instructions Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.dimen16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_list_numbered_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Step-by-Step Instructions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.steps.asMap().entries.map((entry) {
                  final stepNumber = entry.key + 1;
                  final stepText = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryLight,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '$stepNumber',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            stepText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Pro-Tip Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimens.dimen14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // soft warm amber
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFF57F17),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.proTip,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5D4037),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomControls(ThemeData theme, bool isLastPage) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.dimen16,
        vertical: AppDimens.dimen12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_tutorialPages.length, (index) {
              final isCurrent = _currentPage == index;
              return GestureDetector(
                onTap: () => _goToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primary : AppColors.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Navigation Action Buttons
          Row(
            children: [
              // Previous Button
              if (_currentPage > 0)
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => _goToPage(_currentPage - 1),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(flex: 2),

              const SizedBox(width: 12),

              // Next or Done Button
              Expanded(
                flex: 3,
                child: AppTextButton(
                  title: isLastPage ? 'Done' : 'Next Step →',
                  borderRadius: AppDimens.dimen12,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  onPressed: () {
                    if (isLastPage) {
                      _completeTutorial();
                    } else {
                      _goToPage(_currentPage + 1);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TUTORIAL SLIDES DEFINITION & MOCKUP PREVIEWS
  // ---------------------------------------------------------------------------

  static final List<TutorialStepData> _tutorialPages = [
    // 1. APP OVERVIEW
    TutorialStepData(
      topicBadge: 'STEP 1 OF 6 • OVERVIEW',
      title: 'How KharchMate Works',
      subtitle:
          'Track income, expenses, and manage budgets in seconds without complicated finance jargon.',
      tabIcon: Icons.home_rounded,
      tabLabel: 'App Tour',
      steps: [
        'Total Balance: Displays your real-time cash flow calculated from all recorded transactions.',
        'Month Selector: Tap the month bar at the top of the dashboard to view past or upcoming periods.',
        'Center "+" Action: Press the big orange button from anywhere to record money in or out.',
        'Bottom Navigation: Easily navigate between Home, Transactions, Reports, and Settings.',
      ],
      proTip:
          'KharchMate is 100% offline and secure. None of your personal or financial data ever leaves your device.',
      previewWidget: _buildOverviewPreview(),
    ),

    // 2. HOW TO ADD CATEGORY
    TutorialStepData(
      topicBadge: 'STEP 2 OF 6 • CATEGORIES',
      title: 'How to Add a Category',
      subtitle:
          'Create personalized categories tailored for groceries, rent, side hustles, or entertainment.',
      tabIcon: Icons.grid_view_rounded,
      tabLabel: 'Add Category',
      steps: [
        'Open Categories: Navigate to Settings → Categories (or tap "+ Add" chip when logging a transaction).',
        'Choose Type: Select whether your category is for Expense or Income.',
        'Tap "+ Add Category": Tap the button at the bottom or top right.',
        'Name & Icon: Enter a clear category name and choose an intuitive icon (e.g. food, fuel, gym, bill).',
        'Pick a Color: Assign a distinctive color to spot this category instantly on your charts.',
        'Save: Tap "Save Category" to make it immediately active for future entries.',
      ],
      proTip:
          'Default categories (like Groceries, Salary, Shopping) are pre-loaded for you. You can create as many custom ones as you need!',
      previewWidget: _buildCategoryPreview(),
    ),

    // 3. HOW TO ADD INCOME
    TutorialStepData(
      topicBadge: 'STEP 3 OF 6 • INCOME',
      title: 'How to Add Income',
      subtitle:
          'Log your monthly salary, freelance earnings, investments, cashback, or gifts effortlessly.',
      tabIcon: Icons.arrow_downward_rounded,
      tabLabel: 'Add Income',
      steps: [
        'Tap the "+" button located in the center of the bottom navigation bar.',
        'Switch to "Income": Tap the green Income tab at the top toggle.',
        'Enter Amount: Type how much you received in your chosen currency.',
        'Select Category: Tap an income category (e.g. Salary, Freelance, Dividend, Bonus).',
        'Select Payment Mode: Choose where money was received (Bank, Cash, UPI, Card).',
        'Pick Date & Note: Keep the default today date or pick a past date, and add an optional memo.',
        'Tap "Save Transaction": Your balance and monthly income increase right away!',
      ],
      proTip:
          'Always log recurring income as soon as it arrives so your monthly budget calculations stay 100% accurate.',
      previewWidget: _buildIncomePreview(),
    ),

    // 4. HOW TO ADD EXPENSE
    TutorialStepData(
      topicBadge: 'STEP 4 OF 6 • EXPENSE',
      title: 'How to Add Expense',
      subtitle:
          'Keep your spending under control by logging daily expenses in less than 5 seconds.',
      tabIcon: Icons.arrow_upward_rounded,
      tabLabel: 'Add Expense',
      steps: [
        'Tap the "+" button located at the bottom navigation bar.',
        'Expense is Selected by Default: Notice the red Expense toggle is active.',
        'Enter Amount: Input the exact amount spent.',
        'Select Category: Tap the relevant chip (Food, Shopping, Fuel, Rent, Health, etc.).',
        'Select Payment Mode: Mark if you paid via UPI (GPay/PhonePe), Cash, Bank, or Credit Card.',
        'Date & Remarks: Select the date/time and add a quick note (e.g. "Dinner with team").',
        'Tap "Save Transaction": Your dashboard, savings, and category pie charts update immediately!',
      ],
      proTip:
          'You can filter and search your logged expenses anytime from the Transactions tab by date, category, or payment mode.',
      previewWidget: _buildExpensePreview(),
    ),

    // 5. SMART BUDGETS
    TutorialStepData(
      topicBadge: 'STEP 5 OF 6 • BUDGETS',
      title: 'How to Set Budgets & Limits',
      subtitle:
          'Avoid month-end surprises with category spending limits and real-time visual alerts.',
      tabIcon: Icons.account_balance_wallet_rounded,
      tabLabel: 'Budgets',
      steps: [
        'Allocate Limits: Set a planned spending cap for categories like Dining, Shopping, or Travel.',
        'Color Progress Bar: Green means safe spending, Amber/Orange warns you as you approach 80%.',
        'Over-Budget Alert: If spending hits 100%, the bar turns red to signal an over-budget condition.',
        'Review Before Buying: Check your budget health before making big purchases to protect your savings.',
      ],
      proTip:
          'Keeping non-essential expenses (like eating out or gadgets) within strict limits is the fastest way to grow your monthly savings.',
      previewWidget: _buildBudgetPreview(),
    ),

    // 6. VISUAL REPORTS
    TutorialStepData(
      topicBadge: 'STEP 6 OF 6 • ANALYTICS',
      title: 'Visual Reports & Analytics',
      subtitle:
          'Understand your spending patterns through interactive pie charts and monthly breakdowns.',
      tabIcon: Icons.pie_chart_rounded,
      tabLabel: 'Reports',
      steps: [
        'Tap "Reports" on the bottom navigation bar.',
        'Interactive Pie Chart: Tap any color slice to see exact category totals and percentages.',
        'Category Breakdown: See a ranked list of where most of your money went this month.',
        'Month Comparison: Switch months to compare spending habits and monitor your financial growth.',
      ],
      proTip:
          'Review your Reports at the end of each week to pinpoint small leaks and trim unwanted recurring subscriptions.',
      previewWidget: _buildReportsPreview(),
    ),
  ];

  // ---------------------------------------------------------------------------
  // MINI VISUAL MOCKUP WIDGETS
  // ---------------------------------------------------------------------------

  static Widget _buildOverviewPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          // Total Balance Card Mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.linerGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '₹45,200.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '+₹65,000 Income',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '-₹19,800 Expense',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Navigation pointers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureBadge(
                Icons.calendar_month_rounded,
                'Month Picker',
                AppColors.primary,
              ),
              _buildFeatureBadge(
                Icons.add_circle_rounded,
                'Quick "+" Log',
                const Color(0xFFE65100),
              ),
              _buildFeatureBadge(
                Icons.pie_chart_rounded,
                'Live Reports',
                const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Expense Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Income Category',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Field Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF7E57C2),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Gym & Fitness',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.income,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Color Dots row
          Row(
            children: [
              const Text(
                'Color: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              ...[
                const Color(0xFF7E57C2),
                const Color(0xFFFF9800),
                const Color(0xFF42A5F5),
                const Color(0xFF26A69A),
                const Color(0xFFEF5350),
              ].map(
                (c) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: c == const Color(0xFF7E57C2)
                        ? Border.all(color: AppColors.textPrimary, width: 2)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildIncomePreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          // Income Active Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: const Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.income,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Amount Display Mockup
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.incomeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Received Amount',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+ ₹50,000.00',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.income,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chips
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniChip(
                icon: Icons.work_outline_rounded,
                label: 'Salary',
                color: AppColors.income,
              ),
              _MiniChip(
                icon: Icons.account_balance_rounded,
                label: 'Bank Account',
                color: Color(0xFF1976D2),
              ),
              _MiniChip(
                icon: Icons.today_rounded,
                label: 'Today',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildExpensePreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          // Expense Active Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: const Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Amount Display Mockup
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.expenseLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Spent Amount',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '- ₹350.00',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.expense,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chips
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniChip(
                icon: Icons.fastfood_rounded,
                label: 'Food & Dining',
                color: Color(0xFFFF9800),
              ),
              _MiniChip(
                icon: Icons.qr_code_scanner_rounded,
                label: 'UPI (GPay)',
                color: Color(0xFF7B1FA2),
              ),
              _MiniChip(
                icon: Icons.comment_rounded,
                label: 'Team Lunch',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildBudgetPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.shopping_cart_rounded,
                    color: Color(0xFF7E57C2),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Shopping & Outings',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '82% Used',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: 0.82,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFA000), // Amber warning
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ₹8,200',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                ),
              ),
              Text(
                'Limit: ₹10,000',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildReportsPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'This Month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Category progress bars
          _buildReportBar('Food & Groceries', 0.42, '42%', const Color(0xFFFF9800)),
          const SizedBox(height: 8),
          _buildReportBar('Shopping', 0.28, '28%', const Color(0xFF7E57C2)),
          const SizedBox(height: 8),
          _buildReportBar('Bills & Utilities', 0.18, '18%', const Color(0xFFEF5350)),
          const SizedBox(height: 8),
          _buildReportBar('Transport', 0.12, '12%', const Color(0xFF42A5F5)),
        ],
      ),
    );
  }

  static Widget _buildReportBar(
    String title,
    double progress,
    String percentage,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  static Widget _buildFeatureBadge(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
