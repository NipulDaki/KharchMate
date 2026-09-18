import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final DatabaseService _dbService;
  List<CategoryModel> _allCategories = [];
  String _selectedTab = 'All'; // 'All' | 'Expense' | 'Income'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isExpenseExpanded = true;
  bool _isIncomeExpanded = true;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _initAndLoadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initAndLoadCategories() async {
    try {
      // Ensure predefined categories exist even if none were created yet
      await _dbService.ensurePredefinedCategories();
      final categories = await _dbService.getAllCategories();

      if (mounted) {
        setState(() {
          _allCategories = categories;
        });
      }
    } catch (_) {}
  }

  List<CategoryModel> get _filteredExpenseCategories {
    return _allCategories.where((c) {
      final isExpense = c.type == CategoryType.expense || c.type == CategoryType.both;
      if (!isExpense) return false;
      if (_searchQuery.isNotEmpty) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  List<CategoryModel> get _filteredIncomeCategories {
    return _allCategories.where((c) {
      final isIncome = c.type == CategoryType.income || c.type == CategoryType.both;
      if (!isIncome) return false;
      if (_searchQuery.isNotEmpty) {
        return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && category.id != null) {
      try {
        await _dbService.deleteCategory(category.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "${category.name}" deleted.'),
              backgroundColor: AppColors.primary,
            ),
          );
          _initAndLoadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', '')),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showExpense = _selectedTab == 'All' || _selectedTab == 'Expense';
    final showIncome = _selectedTab == 'All' || _selectedTab == 'Income';

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.dashboard.path);
            }
          },
        ),
        title: Text(
          'Categories',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await context.push<bool>(AppRoutes.addCategory.path);
          if (result == true) {
            _initAndLoadCategories();
          }
        },
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
      body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _initAndLoadCategories,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.dimen16,
                  vertical: AppDimens.dimen12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Filter Chips Row: [All] [Expense] [Income]
                    _buildFilterTabs(),

                    const SizedBox(height: AppDimens.dimen16),

                    // 2. Search Field
                    _buildSearchBar(),

                    const SizedBox(height: AppDimens.dimen20),

                    // 3. Expense Section
                    if (showExpense) ...[
                      _buildSectionHeader(
                        title: 'Expense',
                        icon: Icons.shopping_bag_outlined,
                        iconColor: AppColors.primary,
                        count: _filteredExpenseCategories.length,
                        isExpanded: _isExpenseExpanded,
                        onToggle: () {
                          setState(() {
                            _isExpenseExpanded = !_isExpenseExpanded;
                          });
                        },
                      ),
                      if (_isExpenseExpanded) ...[
                        const SizedBox(height: AppDimens.dimen8),
                        if (_filteredExpenseCategories.isEmpty)
                          _buildEmptyState('No expense categories found')
                        else
                          ..._filteredExpenseCategories.map(_buildCategoryTile),
                      ],
                      const SizedBox(height: AppDimens.dimen20),
                    ],

                    // 4. Income Section
                    if (showIncome) ...[
                      _buildSectionHeader(
                        title: 'Income',
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.income,
                        count: _filteredIncomeCategories.length,
                        isExpanded: _isIncomeExpanded,
                        onToggle: () {
                          setState(() {
                            _isIncomeExpanded = !_isIncomeExpanded;
                          });
                        },
                      ),
                      if (_isIncomeExpanded) ...[
                        const SizedBox(height: AppDimens.dimen8),
                        if (_filteredIncomeCategories.isEmpty)
                          _buildEmptyState('No income categories found')
                        else
                          ..._filteredIncomeCategories.map(_buildCategoryTile),
                      ],
                    ],

                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['All', 'Expense', 'Income'];

    return Row(
      children: tabs.map((tab) {
        final isSelected = _selectedTab == tab;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedTab = tab);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.linerGradient : null,
                color: isSelected ? null : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.borderColor,
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() => _searchQuery = val.trim());
        },
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    final typeLabel = category.type == CategoryType.income ? 'Income' : 'Expense';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.colorValue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.iconData,
              color: category.colorValue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Name and Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Delete Action Button (No edit option as requested)
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.expense,
              size: 20,
            ),
            tooltip: 'Delete Category',
            onPressed: () => _confirmDelete(category),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 13,
        ),
      ),
    );
  }
}
