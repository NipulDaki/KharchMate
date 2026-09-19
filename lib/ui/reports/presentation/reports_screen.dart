import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/financial_summary.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/month_year_picker_sheet.dart';

enum ReportTab { overview, category, trends }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final DatabaseService _dbService;
  StreamSubscription<void>? _transactionSubscription;
  StreamSubscription<UserProfile>? _userProfileSubscription;
  String _currencySymbol = '₹';
  FinancialSummary _summary = FinancialSummary.empty();
  List<MonthlyTrend> _trends = [];
  DateTime _selectedDate = DateTime.now();
  ReportTab _selectedTab = ReportTab.overview;
  int _touchedPieIndex = -1;

  static const Color _chartIncomeColor = Color(0xFFF57C00);
  static const Color _chartExpenseColor = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadReportData();
    _transactionSubscription = _dbService.onTransactionChanged.listen((_) {
      if (mounted) {
        _loadReportData();
      }
    });
    _userProfileSubscription = _dbService.onUserProfileChanged.listen((profile) {
      if (mounted && profile.currencySymbol.isNotEmpty) {
        setState(() {
          _currencySymbol = profile.currencySymbol;
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

  Future<void> _loadReportData() async {
    try {
      final user = await _dbService.getUserProfile();
      final summary = await _dbService.getMonthlySummary(
        _selectedDate.month,
        _selectedDate.year,
      );
      final trends = await _dbService.getMonthlyTrends(
        _selectedDate.year,
        count: 6,
        endMonth: _selectedDate.month,
      );

      if (mounted) {
        setState(() {
          if (user != null && user.currencySymbol.isNotEmpty) {
            _currencySymbol = user.currencySymbol;
          }
          _summary = summary;
          _trends = trends;
          _touchedPieIndex = -1;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () async {
          final result = await context.push<dynamic>(AppRoutes.addTransaction.path);
          if (result != null && mounted) {
            _loadReportData();
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
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen16,
                  vertical: AppDimens.dimen12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Text(
                      'Reports',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen16),

                    // Segmented Tabs: Overview | Category | Trends
                    _buildSegmentTabs(),
                    const SizedBox(height: AppDimens.dimen16),

                    // Month Selector Dropdown
                    _buildMonthSelector(context),
                    const SizedBox(height: AppDimens.dimen16),

                    // Tab Content
                    if (_selectedTab == ReportTab.overview)
                      _buildOverviewContent(theme)
                    else if (_selectedTab == ReportTab.category)
                      _buildCategoryContent(theme)
                    else
                      _buildTrendsContent(theme),

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

  // ===========================================================================
  // TOP SEGMENTED TABS
  // ===========================================================================
  Widget _buildSegmentTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildSegmentItem('Overview', ReportTab.overview),
          _buildSegmentItem('Category', ReportTab.category),
          _buildSegmentItem('Trends', ReportTab.trends),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String label, ReportTab tab) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != tab) {
            setState(() => _selectedTab = tab);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MONTH SELECTOR
  // ===========================================================================
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
          _loadReportData();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // OVERVIEW TAB CONTENT
  // ===========================================================================
  Widget _buildOverviewContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Income & Total Expense Cards Row
        _buildSummaryCardsRow(theme),
        const SizedBox(height: AppDimens.dimen12),

        // Savings Card with Progress Bar
        _buildSavingsCard(theme),
        const SizedBox(height: AppDimens.dimen20),

        // Income vs Expense Chart Card
        _buildIncomeVsExpenseChartCard(theme),
        const SizedBox(height: AppDimens.dimen20),

        // Top Spending Categories Card
        _buildTopSpendingCategoriesCard(theme),
      ],
    );
  }

  Widget _buildSummaryCardsRow(ThemeData theme) {
    return Row(
      children: [
        // Total Income Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.dimen14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Income',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _summary.formattedIncome(symbol: _currencySymbol),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
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

        // Total Expense Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.dimen14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expense',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _summary.formattedExpense(symbol: _currencySymbol),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
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
    final savingsPercent = _summary.totalIncome > 0
        ? (_summary.savings / _summary.totalIncome).clamp(0.0, 1.0)
        : 0.0;
    final percentLabel = _summary.totalIncome > 0
        ? '${(savingsPercent * 100).toStringAsFixed(0)}% of income'
        : '0% of income';

    return Container(
      padding: const EdgeInsets.all(AppDimens.dimen14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Savings',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _summary.formattedSavings(symbol: _currencySymbol),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: savingsPercent,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF059669),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INCOME VS EXPENSE BAR CHART
  // ===========================================================================
  Widget _buildIncomeVsExpenseChartCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expense',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.dimen16),
          SizedBox(
            height: 200,
            child: _trends.isEmpty
                ? Center(
                    child: Text(
                      'No trend data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  )
                : _buildBarChart(),
          ),
          const SizedBox(height: AppDimens.dimen12),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(_chartIncomeColor, 'Income'),
              const SizedBox(width: 24),
              _buildLegendItem(_chartExpenseColor, 'Expense'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    double maxVal = 0;
    for (final trend in _trends) {
      if (trend.income > maxVal) maxVal = trend.income;
      if (trend.expense > maxVal) maxVal = trend.expense;
    }
    if (maxVal <= 0) maxVal = 1000;
    final maxY = maxVal * 1.25;

    final barGroups = _trends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;

      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: trend.income,
            color: _chartIncomeColor,
            width: 9,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
          BarChartRodData(
            toY: trend.expense,
            color: _chartExpenseColor,
            width: 9,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 3 : 1,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFF1F5F9),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: maxY > 0 ? maxY / 3 : 1,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  );
                }
                String formatted;
                if (value >= 100000) {
                  formatted = '${(value / 100000).toStringAsFixed(0)}L';
                } else if (value >= 1000) {
                  formatted = '${(value / 1000).toStringAsFixed(0)}k';
                } else {
                  formatted = value.toStringAsFixed(0);
                }
                return Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _trends.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _trends[index].monthLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isIncome = rodIndex == 0;
              final type = isIncome ? 'Income' : 'Expense';
              final amount = NumberFormat('#,##,###').format(rod.toY);
              return BarTooltipItem(
                '$type: $_currencySymbol$amount',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TOP SPENDING CATEGORIES SECTION
  // ===========================================================================
  Widget _buildTopSpendingCategoriesCard(ThemeData theme) {
    final breakdown = _summary.categoryBreakdown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Spending Categories',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.dimen16),
          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No expense recorded for this month',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdown.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = breakdown[index];
                final progress = (item.percentage / 100).clamp(0.0, 1.0);

                return Row(
                  children: [
                    // Category Icon Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.colorValue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.iconData,
                        color: item.colorValue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title, Percentage & Progress Bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.categoryName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.formattedPercentage,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CATEGORY TAB CONTENT
  // ===========================================================================
  Widget _buildCategoryContent(ThemeData theme) {
    final breakdown = _summary.categoryBreakdown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen16),
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
              Text(
                'Category Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (breakdown.isNotEmpty)
                Text(
                  _summary.formattedExpense(symbol: _currencySymbol),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.expense,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.dimen16),
          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No expense recorded for this month',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedPieIndex = -1;
                                return;
                              }
                              _touchedPieIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
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
            const SizedBox(height: AppDimens.dimen20),
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
                      vertical: 8,
                      horizontal: 8,
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedAmount(symbol: _currencySymbol),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.formattedPercentage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? item.colorValue
                                : AppColors.textPrimary,
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
              style: TextStyle(
                color: touchedItem.colorValue,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              touchedItem.formattedAmount(symbol: _currencySymbol),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            Text(
              touchedItem.formattedPercentage,
              style: const TextStyle(
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
        const Text(
          'Total',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _summary.formattedExpense(symbol: _currencySymbol),
          style: const TextStyle(
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
          shadows: const [
            Shadow(
              color: Colors.black38,
              blurRadius: 2,
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  // ===========================================================================
  // TRENDS TAB CONTENT
  // ===========================================================================
  Widget _buildTrendsContent(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.dimen16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends (Last 6 Months)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.dimen16),
          if (_trends.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No trend data recorded',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trends.length,
              separatorBuilder: (_, _) => const Divider(
                height: 16,
                color: AppColors.dividerColor,
              ),
              itemBuilder: (context, index) {
                final trend = _trends[index];
                final net = trend.netSavings;
                final isPositive = net >= 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trend.monthLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Income: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '$_currencySymbol${NumberFormat('#,##,###').format(trend.income)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text(
                                  'Expense: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '$_currencySymbol${NumberFormat('#,##,###').format(trend.expense)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Net',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${isPositive ? '+' : ''}$_currencySymbol${NumberFormat('#,##,###').format(net)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isPositive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION BAR
  // ===========================================================================
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
            _buildNavItem(Icons.home_rounded, 'Home', false, () {
              context.go(AppRoutes.dashboard.path);
            }),
            _buildNavItem(Icons.receipt_long_rounded, 'Transactions', false, () {
              context.go(AppRoutes.transaction.path);
            }),
            const SizedBox(width: 48), // Spacer for center FAB
            _buildNavItem(Icons.bar_chart_rounded, 'Reports', true, () {}),
            _buildNavItem(Icons.settings_rounded, 'Settings', false, () {
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
