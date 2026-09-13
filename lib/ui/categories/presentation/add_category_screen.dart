import 'package:flutter/material.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final DatabaseService _dbService;

  CategoryType _selectedType = CategoryType.expense;
  String _selectedIconKey = 'fastfood';
  String _selectedColorHex = '#FF9800';
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _iconOptions = [
    {'key': 'fastfood', 'icon': Icons.restaurant},
    {'key': 'home', 'icon': Icons.home_rounded},
    {'key': 'directions_car', 'icon': Icons.directions_car_rounded},
    {'key': 'shopping_bag', 'icon': Icons.shopping_bag_rounded},
    {'key': 'receipt_long', 'icon': Icons.receipt_long_rounded},
    {'key': 'medical_services', 'icon': Icons.medical_services_rounded},
    {'key': 'sports_esports', 'icon': Icons.sports_esports_rounded},
    {'key': 'school', 'icon': Icons.school_rounded},
    {'key': 'flight', 'icon': Icons.flight_rounded},
    {'key': 'spa', 'icon': Icons.spa_rounded},
    {'key': 'shopping_cart', 'icon': Icons.shopping_cart_rounded},
    {'key': 'account_balance', 'icon': Icons.account_balance_rounded},
    {'key': 'shield', 'icon': Icons.shield_rounded},
    {'key': 'card_giftcard', 'icon': Icons.card_giftcard_rounded},
    {'key': 'more_horiz', 'icon': Icons.more_horiz_rounded},
    {'key': 'account_balance_wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'key': 'stars', 'icon': Icons.stars_rounded},
    {'key': 'trending_up', 'icon': Icons.trending_up_rounded},
    {'key': 'laptop_mac', 'icon': Icons.laptop_mac_rounded},
    {'key': 'store', 'icon': Icons.store_rounded},
  ];

  static const List<String> _colorOptions = [
    '#FF9800', // Orange
    '#EF5350', // Coral Red
    '#FFCA28', // Amber Yellow
    '#66BB6A', // Green
    '#26A69A', // Teal
    '#42A5F5', // Blue
    '#7E57C2', // Indigo / Purple
    '#78909C', // Slate Gray
  ];

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData _iconFromKey(String key) {
    final match = _iconOptions.firstWhere(
      (opt) => opt['key'] == key,
      orElse: () => {'icon': Icons.category_rounded},
    );
    return match['icon'] as IconData;
  }

  Future<void> _saveCategory() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final categoryName = _nameController.text.trim();
    if (categoryName.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final newCategory = CategoryModel(
        name: categoryName,
        type: _selectedType,
        icon: _selectedIconKey,
        color: _selectedColorHex,
        isDefault: false,
        createdAt: DateTime.now(),
      );

      await _dbService.insertCategory(newCategory);

      if (mounted) {
        setState(() => _isSaving = false);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add category: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = _colorFromHex(_selectedColorHex);
    final activeIcon = _iconFromKey(_selectedIconKey);

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
          'Add Category',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.dimen20,
                vertical: AppDimens.dimen16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Centered Live Preview
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              activeIcon,
                              size: 46,
                              color: activeColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen24),

                    // 2. Name Input
                    Text(
                      'Name',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Enter category name (e.g. Food)',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.label_outline_rounded,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category name';
                          }
                          if (value.trim().length < 2) {
                            return 'Category name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen20),

                    // 3. Type Selector Toggle: [Expense] [Income]
                    Text(
                      'Type',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen8),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedType = CategoryType.expense);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _selectedType == CategoryType.expense
                                      ? AppColors.linerGradient
                                      : null,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _selectedType == CategoryType.expense
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                    fontWeight: _selectedType == CategoryType.expense
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedType = CategoryType.income);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: _selectedType == CategoryType.income
                                      ? AppColors.linerGradient
                                      : null,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: _selectedType == CategoryType.income
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                    fontWeight: _selectedType == CategoryType.income
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen24),

                    // 4. Select Icon Grid
                    Text(
                      'Select Icon',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _iconOptions.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final item = _iconOptions[index];
                        final key = item['key'] as String;
                        final icon = item['icon'] as IconData;
                        final isSelected = _selectedIconKey == key;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIconKey = key);
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : const Color(0xFFF7F9FB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: AppColors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimens.dimen24),

                    // 5. Select Color Palette
                    Text(
                      'Select Color',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.dimen12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _colorOptions.map((hex) {
                        final isSelected = _selectedColorHex == hex;
                        final color = _colorFromHex(hex);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColorHex = hex);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: color, width: 3)
                                  : null,
                            ),
                            padding: EdgeInsets.all(isSelected ? 2 : 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppDimens.dimen36),

                    // 6. Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: AppTextButton(
                        title: 'Save',
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        onPressed: _isSaving ? null : _saveCategory,
                      ),
                    ),

                    const SizedBox(height: AppDimens.dimen24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
