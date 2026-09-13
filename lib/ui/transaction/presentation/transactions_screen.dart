import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/app_loader.dart';
import 'package:kharch_mate/widgets/month_year_picker_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final DatabaseService _dbService;

  List<TransactionItem> _transactions = [];
  bool _isLoading = true;
  String _currencySymbol = '₹';

  // Filters
  TransactionType? _selectedType; // null = All, income, expense
  DateTime? _selectedMonth = DateTime.now(); // null = All Time
  CategoryModel? _selectedCategoryFilter;
  String _sortOrder = 'newest'; // newest, oldest, highest, lowest

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = await _dbService.getUserProfile();
      if (user != null && user.currencySymbol.isNotEmpty) {
        _currencySymbol = user.currencySymbol;
      }
    } catch (_) {}
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final query = _searchController.text.trim();
      final list = await _dbService.getTransactions(
        type: _selectedType,
        searchQuery: query.isNotEmpty ? query : null,
        month: _selectedMonth?.month,
        year: _selectedMonth?.year,
        categoryId: _selectedCategoryFilter?.id,
      );

      // Apply client-side sorting if needed
      if (_sortOrder == 'oldest') {
        list.sort((a, b) => a.date.compareTo(b.date));
      } else if (_sortOrder == 'highest') {
        list.sort((a, b) => b.amount.compareTo(a.amount));
      } else if (_sortOrder == 'lowest') {
        list.sort((a, b) => a.amount.compareTo(b.amount));
      } else {
        // Default: newest first
        list.sort((a, b) => b.date.compareTo(a.date));
      }

      if (mounted) {
        setState(() {
          _transactions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadTransactions();
    });
  }

  void _onTypeFilterChanged(TransactionType? type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    _loadTransactions();
  }

  Future<void> _showMonthPicker() async {
    final result = await showMonthYearPickerSheet(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      allowAllMonths: true,
      isAllMonths: _selectedMonth == null,
    );

    if (result != null) {
      if (result.isAllMonths) {
        setState(() => _selectedMonth = null);
      } else if (result.date != null) {
        setState(() => _selectedMonth = result.date);
      }
      _loadTransactions();
    }
  }

  Future<void> _showFilterSheet() async {
    List<CategoryModel> categories = [];
    try {
      final allCats = await _dbService.getAllCategories();
      categories = allCats;
    } catch (_) {}

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String tempSort = _sortOrder;
        CategoryModel? tempCategory = _selectedCategoryFilter;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempSort = 'newest';
                              tempCategory = null;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip(
                          'Newest First',
                          'newest',
                          tempSort,
                          (val) => setSheetState(() => tempSort = val),
                        ),
                        _buildSortChip(
                          'Oldest First',
                          'oldest',
                          tempSort,
                          (val) => setSheetState(() => tempSort = val),
                        ),
                        _buildSortChip(
                          'Highest Amount',
                          'highest',
                          tempSort,
                          (val) => setSheetState(() => tempSort = val),
                        ),
                        _buildSortChip(
                          'Lowest Amount',
                          'lowest',
                          tempSort,
                          (val) => setSheetState(() => tempSort = val),
                        ),
                      ],
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = tempCategory == null;
                              return ChoiceChip(
                                label: Text(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAll
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                    fontWeight: isAll
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                selected: isAll,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.white,
                                surfaceTintColor: Colors.transparent,
                                side: BorderSide(
                                  color: isAll
                                      ? AppColors.primary
                                      : AppColors.borderColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onSelected: (_) {
                                  setSheetState(() => tempCategory = null);
                                },
                              );
                            }
                            final cat = categories[index - 1];
                            final isSel = tempCategory?.id == cat.id;
                            return ChoiceChip(
                              label: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSel
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.white,
                              surfaceTintColor: Colors.transparent,
                              side: BorderSide(
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.borderColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (_) {
                                setSheetState(() => tempCategory = cat);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _sortOrder = tempSort;
                            _selectedCategoryFilter = tempCategory;
                          });
                          Navigator.of(ctx).pop();
                          _loadTransactions();
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    String currentSort,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = currentSort == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  Future<void> _openTransactionDetails(TransactionItem tx) async {
    final result = await context.push<dynamic>(
      AppRoutes.transactionDetails.path,
      extra: tx,
    );
    if (result != null) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthText = _selectedMonth != null
        ? DateFormat('MMMM yyyy').format(_selectedMonth!)
        : 'All Months';

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
          if (result != null) {
            _loadTransactions();
          }
        },
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadTransactions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Title
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimens.dimen20,
                  right: AppDimens.dimen20,
                  top: AppDimens.dimen16,
                  bottom: AppDimens.dimen12,
                ),
                child: Text(
                  'Transactions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ),

              // 2. Segmented Filter Tabs: All, Income, Expense
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen20,
                ),
                child: _buildTypeSegmentTabs(),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // 3. Live Search Input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen20,
                ),
                child: _buildSearchBar(),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // 4. Month Selector & Filter Funnel Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen20,
                ),
                child: Row(
                  children: [
                    // Month selector pill
                    Expanded(
                      child: InkWell(
                        onTap: _showMonthPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  monthText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filter icon button
                    InkWell(
                      onTap: _showFilterSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCategoryFilter != null ||
                                    _sortOrder != 'newest'
                                ? AppColors.primary
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 20,
                          color: _selectedCategoryFilter != null ||
                                  _sortOrder != 'newest'
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.dimen12),

              // 5. Transaction List View
              Expanded(
                child: _isLoading
                    ? const Center(child: AppLoader(loadingText: 'Loading...'))
                    : _transactions.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.dimen20,
                              vertical: AppDimens.dimen8,
                            ),
                            itemCount: _transactions.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final tx = _transactions[index];
                              return _buildTransactionItem(tx);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegmentTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildSegmentPill('All', null),
          _buildSegmentPill('Income', TransactionType.income),
          _buildSegmentPill('Expense', TransactionType.expense),
        ],
      ),
    );
  }

  Widget _buildSegmentPill(String label, TransactionType? type) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTypeFilterChanged(type),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _loadTransactions();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem tx) {
    final isIncome = tx.type.isIncome;
    final amountFormatted = tx.formattedAmount(currencySymbol: _currencySymbol);

    return InkWell(
      onTap: () => _openTransactionDetails(tx),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.dimen12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            // Category Icon Circular Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tx.categoryColorValue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tx.categoryIconData,
                color: tx.categoryColorValue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Title and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.displayTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Amount with Sign
            Text(
              amountFormatted,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F4F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your filters, search term, or add a new transaction.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
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
            _buildNavItem(Icons.home_rounded, 'Home', false, () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.dashboard.path);
              }
            }),
            _buildNavItem(
              Icons.receipt_long_rounded,
              'Transactions',
              true,
              () {},
            ),
            const SizedBox(width: 48), // Spacer for center FAB
            _buildNavItem(Icons.bar_chart_rounded, 'Reports', false, () {
              context.push(AppRoutes.report.path);
            }),
            _buildNavItem(Icons.settings_rounded, 'Settings', false, () {
              context.push(AppRoutes.settings.path);
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
