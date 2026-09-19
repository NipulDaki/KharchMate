import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/financial_summary.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/dashboard_banner_ad_widget.dart';
import 'package:kharch_mate/widgets/month_year_picker_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DatabaseService _dbService;
  StreamSubscription<void>? _transactionSubscription;
  StreamSubscription<UserProfile>? _userProfileSubscription;
  UserProfile? _userProfile;
  FinancialSummary _summary = FinancialSummary.empty();
  List<TransactionItem> _recentTransactions = [];
  bool _isBalanceVisible = true;
  DateTime _selectedDate = DateTime.now();
  int _touchedPieIndex = -1;

  String get _currencySymbol => _userProfile?.currencySymbol ?? '₹';

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadDashboardData();
    _transactionSubscription = _dbService.onTransactionChanged.listen((_) {
      if (mounted) {
        _loadDashboardData();
      }
    });
    _userProfileSubscription = _dbService.onUserProfileChanged.listen((profile) {
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    });
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _dbService.getUserProfile();
      final summary = await _dbService.getMonthlySummary(
        _selectedDate.month,
        _selectedDate.year,
      );
      final recent = await _dbService.getRecentTransactions(limit: 5);

      if (mounted) {
        setState(() {
          _userProfile = user;
          _summary = summary;
          _recentTransactions = recent.take(5).toList();
          _touchedPieIndex = -1;
        });
      }
    } catch (_) {}
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = _userProfile?.name.trim().isNotEmpty == true
        ? _userProfile!.name.split(' ').first
        : 'User';
    final userInitials = _userProfile?.initials ?? 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () async {
          final result = await context.push<dynamic>(
            AppRoutes.addTransaction.path,
          );
          if (result != null && mounted) {
            _loadDashboardData();
          }
        },
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.dimen12),

                    // Top Header: Greeting, User Name, Notification, Avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push(AppRoutes.userProfile.path);
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  userInitials,
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.dimen16),

                    // Month Selector Dropdown
                    _buildMonthSelector(context),

                    const SizedBox(height: AppDimens.dimen16),

                    // Total Balance Card
                    _buildTotalBalanceCard(theme),

                    const SizedBox(height: AppDimens.dimen12),

                    // Income & Expenses Summary Row
                    _buildIncomeExpenseRow(theme),

                    const SizedBox(height: AppDimens.dimen12),

                    // Savings Card
                    _buildSavingsCard(theme),

                    const SizedBox(height: AppDimens.dimen16),

                    // Inline Banner Ad (above Pie Chart)
                    const DashboardBannerAdWidget(),

                    const SizedBox(height: AppDimens.dimen8),

                    // Expense by Category Section
                    _buildExpenseByCategory(theme),

                    const SizedBox(height: AppDimens.dimen24),

                    // Recent Transactions
                    _buildRecentTransactions(theme),

                    const SizedBox(height: AppDimens.dimen40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);

    return InkWell(
      onTap: () async {
        final result = await showMonthYearPickerSheet(
          context: context,
          initialDate: _selectedDate,
        );
        if (result != null && result.date != null) {
          setState(() => _selectedDate = result.date!);
          _loadDashboardData();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen20),
      decoration: BoxDecoration(
        gradient: AppColors.linerGradient,
        borderRadius: BorderRadius.circular(AppDimens.dimen16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Total Balance",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Icon(
                      _isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.white,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.dimen8),
          Text(
            _isBalanceVisible
                ? _summary.formattedBalance(symbol: _currencySymbol)
                : '••••••••',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow(ThemeData theme) {
    return Row(
      children: [
        // Income
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.dimen16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.dimen16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.incomeLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _summary.formattedIncome(symbol: _currencySymbol),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.income,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expenses
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.dimen16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.dimen16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.expenseLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.expense,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expenses",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _summary.formattedExpense(symbol: _currencySymbol),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.dimen16,
        vertical: AppDimens.dimen14,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.dimen16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.savingsLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: AppColors.savings,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Savings",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _summary.formattedSavings(symbol: _currencySymbol),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.savings,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textHint,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseByCategory(ThemeData theme) {
    final breakdown = _summary.categoryBreakdown;
    final hasExpenses = breakdown.isNotEmpty && _summary.totalExpense > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.dimen16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expense by Category",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasExpenses)
                Text(
                  _summary.formattedExpense(symbol: _currencySymbol),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.dimen16),
          if (!hasExpenses)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "No expense recorded for this month",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          else ...[
            // Pie Chart
            Center(
              child: SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedPieIndex = -1;
                                    return;
                                  }
                                  _touchedPieIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 46,
                        startDegreeOffset: -90,
                        sections: _buildPieChartSections(breakdown),
                      ),
                    ),
                    _buildPieCenterInfo(theme, breakdown),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.dimen16),
            // Category breakdown items
            Column(
              children: breakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _touchedPieIndex == index;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _touchedPieIndex = _touchedPieIndex == index ? -1 : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.colorValue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.colorValue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedAmount(symbol: _currencySymbol),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.formattedPercentage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? item.colorValue
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPieCenterInfo(
    ThemeData theme,
    List<CategorySpending> breakdown,
  ) {
    if (_touchedPieIndex >= 0 && _touchedPieIndex < breakdown.length) {
      final touchedItem = breakdown[_touchedPieIndex];
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              touchedItem.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: touchedItem.colorValue,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              touchedItem.formattedAmount(symbol: _currencySymbol),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            Text(
              touchedItem.formattedPercentage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Total",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _summary.formattedExpense(symbol: _currencySymbol),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<CategorySpending> breakdown,
  ) {
    return breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedPieIndex;
      final radius = isTouched ? 34.0 : 26.0;
      final showTitle = isTouched || item.percentage >= 8.0;

      return PieChartSectionData(
        color: item.colorValue,
        value: item.amount > 0 ? item.amount : 0.001,
        title: showTitle ? '${item.percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 12.0 : 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  Widget _buildRecentTransactions(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go(AppRoutes.transaction.path);
              },
              child: Text(
                "View All",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.dimen8),
        if (_recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.dimen16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Text(
              "No transactions yet. Tap '+' below to add your first expense or income!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          )
        else
          ..._recentTransactions
              .take(5)
              .map((tx) => _buildTransactionCard(tx, theme)),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionItem tx, ThemeData theme) {
    final isIncome = tx.type.isIncome;

    return InkWell(
      onTap: () async {
        final result = await context.push<dynamic>(
          AppRoutes.transactionDetails.path,
          extra: tx,
        );
        if (result != null && mounted) {
          _loadDashboardData();
        }
      },
      borderRadius: BorderRadius.circular(AppDimens.dimen16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppDimens.dimen12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.dimen16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tx.categoryColorValue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                tx.categoryIconData,
                color: tx.categoryColorValue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.displayTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isIncome ? "Income" : "Expense"} • ${tx.formattedDate}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tx.formattedAmount(currencySymbol: _currencySymbol),
              style: theme.textTheme.titleSmall?.copyWith(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
            _buildNavItem(Icons.home_rounded, "Home", true, () {}),
            _buildNavItem(
              Icons.receipt_long_rounded,
              "Transactions",
              false,
              () {
                context.go(AppRoutes.transaction.path);
              },
            ),
            const SizedBox(width: 48), // Spacer for FAB
            _buildNavItem(Icons.bar_chart_rounded, "Reports", false, () {
              context.go(AppRoutes.report.path);
            }),
            _buildNavItem(Icons.settings_rounded, "Settings", false, () {
              context.go(AppRoutes.settings.path);
            }),
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
