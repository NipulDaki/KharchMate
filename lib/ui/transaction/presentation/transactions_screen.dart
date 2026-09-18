import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/month_year_picker_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final DatabaseService _dbService;

  List<TransactionItem> _transactions = [];
  String _currencySymbol = '₹';

  // Filters
  TransactionType? _selectedType; // null = All, income, expense
  DateTime? _selectedMonth = DateTime.now(); // null = All Time
  DateTime? _selectedDate; // null = not filtering by a specific date
  CategoryModel? _selectedCategoryFilter;
  String _sortOrder = 'newest'; // newest, oldest, highest, lowest

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  StreamSubscription<void>? _transactionSubscription;
  StreamSubscription<UserProfile>? _userProfileSubscription;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _loadInitialData();
    _transactionSubscription = _dbService.onTransactionChanged.listen((_) {
      if (mounted) {
        _loadTransactions();
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
    _searchController.dispose();
    _debounceTimer?.cancel();
    _transactionSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = await _dbService.getUserProfile();
      if (user != null && user.currencySymbol.isNotEmpty) {
        if (mounted) {
          setState(() {
            _currencySymbol = user.currencySymbol;
          });
        } else {
          _currencySymbol = user.currencySymbol;
        }
      }
    } catch (_) {}
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final query = _searchController.text.trim();
      final list = await _dbService.getTransactions(
        type: _selectedType,
        searchQuery: query.isNotEmpty ? query : null,
        date: _selectedDate,
        month: _selectedDate == null ? _selectedMonth?.month : null,
        year: _selectedDate == null ? _selectedMonth?.year : null,
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
        });
      }
    } catch (_) {}
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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _selectedMonth = DateTime(date.year, date.month);
    });
    _loadTransactions();
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
    _loadTransactions();
  }

  Future<void> _selectSpecificDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? _selectedMonth ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _onDateSelected(picked);
    }
  }

  Future<void> _showDateFilterSheet() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      'Filter by Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_selectedDate != null)
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _clearDateFilter();
                        },
                        child: const Text(
                          'Clear Date',
                          style: TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.today_rounded, color: AppColors.primary),
                  ),
                  title: const Text(
                    'Today',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(today),
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  trailing: _selectedDate != null &&
                          _selectedDate!.year == today.year &&
                          _selectedDate!.month == today.month &&
                          _selectedDate!.day == today.day
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _onDateSelected(today);
                  },
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_rounded, color: AppColors.primary),
                  ),
                  title: const Text(
                    'Yesterday',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(yesterday),
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  trailing: _selectedDate != null &&
                          _selectedDate!.year == yesterday.year &&
                          _selectedDate!.month == yesterday.month &&
                          _selectedDate!.day == yesterday.day
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _onDateSelected(yesterday);
                  },
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  ),
                  title: const Text(
                    'Pick a Date from Calendar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _selectedDate != null
                        ? 'Selected: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'
                        : 'Choose any specific day',
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _selectSpecificDate();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMonthPicker() async {
    final result = await showMonthYearPickerSheet(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      allowAllMonths: true,
      isAllMonths: _selectedMonth == null && _selectedDate == null,
    );

    if (result != null) {
      setState(() {
        _selectedDate = null;
        if (result.isAllMonths) {
          _selectedMonth = null;
        } else if (result.date != null) {
          _selectedMonth = result.date;
        }
      });
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
        DateTime? tempDate = _selectedDate;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isToday = tempDate != null &&
                tempDate!.year == today.year &&
                tempDate!.month == today.month &&
                tempDate!.day == today.day;
            final isYesterday = tempDate != null &&
                tempDate!.year == yesterday.year &&
                tempDate!.month == yesterday.month &&
                tempDate!.day == yesterday.day;
            final isCustom = tempDate != null && !isToday && !isYesterday;
            final customDateLabel = isCustom
                ? DateFormat('dd MMM yyyy').format(tempDate!)
                : 'Custom Date...';

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
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
                                tempDate = null;
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
                        'Filter by Date',
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
                          _buildFilterChip(
                            'All / Month',
                            tempDate == null,
                            () => setSheetState(() => tempDate = null),
                          ),
                          _buildFilterChip(
                            'Today',
                            isToday,
                            () => setSheetState(() => tempDate = today),
                          ),
                          _buildFilterChip(
                            'Yesterday',
                            isYesterday,
                            () => setSheetState(() => tempDate = yesterday),
                          ),
                          _buildFilterChip(
                            customDateLabel,
                            isCustom,
                            () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: AppColors.white,
                                        onSurface: AppColors.textPrimary,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setSheetState(() => tempDate = picked);
                              }
                            },
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
                              _selectedDate = tempDate;
                              if (tempDate != null) {
                                _selectedMonth = DateTime(
                                  tempDate!.year,
                                  tempDate!.month,
                                );
                              }
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
  ) {
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
      onSelected: (_) => onSelected(),
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

              // 4. Month Selector, Date Filter & Filter Funnel Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen20,
                ),
                child: Row(
                  children: [
                    // Month or Selected Date selector pill
                    Expanded(
                      child: InkWell(
                        onTap: _selectedDate != null
                            ? _showDateFilterSheet
                            : _showMonthPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedDate != null
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDate != null
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedDate != null
                                    ? Icons.event_available_rounded
                                    : Icons.calendar_today_outlined,
                                size: 16,
                                color: _selectedDate != null
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedDate != null
                                      ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                                      : monthText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedDate != null
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_selectedDate != null)
                                InkWell(
                                  onTap: _clearDateFilter,
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              else
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
                    // Dedicated Date Filter button
                    InkWell(
                      onTap: _showDateFilterSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedDate != null
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDate != null
                                ? AppColors.primary
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.event_outlined,
                          size: 20,
                          color: _selectedDate != null
                              ? AppColors.white
                              : AppColors.textPrimary,
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
                                    _sortOrder != 'newest' ||
                                    _selectedDate != null
                                ? AppColors.primary
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 20,
                          color: _selectedCategoryFilter != null ||
                                  _sortOrder != 'newest' ||
                                  _selectedDate != null
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
                child: _transactions.isEmpty
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
    final dateFiltered = _selectedDate != null;
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
              child: Icon(
                dateFiltered
                    ? Icons.event_busy_rounded
                    : Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dateFiltered
                  ? 'No Transactions on ${DateFormat('dd MMM yyyy').format(_selectedDate!)}'
                  : 'No Transactions Found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateFiltered
                  ? 'There are no transactions recorded for this selected date.'
                  : 'Try changing your filters, search term, or add a new transaction.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
            if (dateFiltered) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _clearDateFilter,
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Clear Date Filter',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
              context.go(AppRoutes.dashboard.path);
            }),
            _buildNavItem(
              Icons.receipt_long_rounded,
              'Transactions',
              true,
              () {},
            ),
            const SizedBox(width: 48), // Spacer for center FAB
            _buildNavItem(Icons.bar_chart_rounded, 'Reports', false, () {
              context.go(AppRoutes.report.path);
            }),
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
