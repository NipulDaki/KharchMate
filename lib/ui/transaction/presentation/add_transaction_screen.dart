import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/enum/payment_mode.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/services/database_service.dart';
import 'package:kharch_mate/widgets/app_text_button.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionItem? initialTransaction;

  const AddTransactionScreen({super.key, this.initialTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final DatabaseService _dbService;

  bool get isEditing => widget.initialTransaction != null;

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  DateTime _selectedDate = DateTime.now();
  PaymentMode? _selectedPaymentMode;
  String _currencySymbol = '₹';
  StreamSubscription<UserProfile>? _userProfileSubscription;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _categoryError;
  String? _paymentMethodError;

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    if (widget.initialTransaction != null) {
      final tx = widget.initialTransaction!;
      _selectedType = tx.type;
      _amountController.text = tx.amount.toStringAsFixed(
        tx.amount.truncateToDouble() == tx.amount ? 0 : 2,
      );
      _selectedDate = tx.date;
      _noteController.text = tx.note ?? '';
      if (tx.paymentMethodName != null) {
        _selectedPaymentMode = PaymentMode.fromString(tx.paymentMethodName!);
      }
    }
    _loadInitialData();
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
    _amountController.dispose();
    _noteController.dispose();
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
      await _dbService.ensurePredefinedCategories();
      await _loadCategoriesForType(_selectedType);
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategoriesForType(TransactionType type) async {
    setState(() => _isLoading = true);
    try {
      final list = type == TransactionType.expense
          ? await _dbService.getExpenseCategories()
          : await _dbService.getIncomeCategories();

      CategoryModel? preselected;
      if (widget.initialTransaction != null &&
          _selectedCategory == null &&
          widget.initialTransaction!.type == type) {
        final tx = widget.initialTransaction!;
        preselected = list.cast<CategoryModel?>().firstWhere(
          (c) =>
              c?.id == tx.categoryId ||
              c?.name.toLowerCase() == tx.categoryName?.toLowerCase(),
          orElse: () => null,
        );
        if (preselected == null && tx.categoryName != null) {
          preselected = CategoryModel(
            id: tx.categoryId,
            name: tx.categoryName!,
            type: CategoryType.fromString(tx.type.toDbString()),
            icon: tx.categoryIcon ?? 'category',
            color: tx.categoryColor ?? '#4A6CF7',
            isDefault: false,
            createdAt: DateTime.now(),
          );
        }
      }

      if (mounted) {
        setState(() {
          _categories = list;
          if (preselected != null) {
            _selectedCategory = preselected;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTypeChanged(TransactionType newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      _selectedCategory = null;
      _categoryError = null;
    });
    _loadCategoriesForType(newType);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showCategoryDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                Text(
                  'Select ${_selectedType == TransactionType.expense ? "Expense" : "Income"} Category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (_categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        color: AppColors.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory?.id == cat.id;

                        return ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cat.colorValue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat.iconData,
                              color: cat.colorValue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            cat.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                              _categoryError = null;
                            });
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentModeDropdown() {
    final modes = PaymentMode.values;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modes.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppColors.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final mode = modes[index];
                    final isSelected = _selectedPaymentMode == mode;

                    return ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          mode.icon,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        mode.displayName,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedPaymentMode = mode;
                          _paymentMethodError = null;
                        });
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _categoryError =
          _selectedCategory == null ? 'Please select a category' : null;
      _paymentMethodError = _selectedPaymentMode == null
          ? 'Please select a payment method'
          : null;
    });

    if (!isFormValid ||
        _selectedCategory == null ||
        _selectedPaymentMode == null) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      if (isEditing) {
        final updated = widget.initialTransaction!.copyWith(
          title: _selectedCategory!.name,
          amount: amount,
          type: _selectedType,
          categoryId:
              _selectedCategory!.id ?? widget.initialTransaction!.categoryId,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.icon,
          categoryColor: _selectedCategory!.color,
          paymentMethodName: _selectedPaymentMode!.displayName,
          date: _selectedDate,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          updatedAt: now,
        );

        await _dbService.updateTransaction(updated);

        if (mounted) {
          setState(() => _isSaving = false);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(updated);
          }
        }
      } else {
        final item = TransactionItem(
          title: _selectedCategory!.name,
          amount: amount,
          type: _selectedType,
          categoryId: _selectedCategory!.id!,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.icon,
          categoryColor: _selectedCategory!.color,
          paymentMethodName: _selectedPaymentMode!.displayName,
          date: _selectedDate,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          createdAt: now,
          updatedAt: now,
        );

        final created = await _dbService.insertTransaction(item);

        if (mounted) {
          setState(() => _isSaving = false);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(created);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatted = DateFormat('dd MMM yyyy').format(_selectedDate);

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
            }
          },
        ),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
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
            horizontal: AppDimens.dimen20,
            vertical: AppDimens.dimen12,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Expense / Income Segmented Toggle
                _buildTypeSegmentedToggle(),

                const SizedBox(height: AppDimens.dimen20),

                // 2. Amount Field (Numpad Keyboard)
                _buildLabel('Amount'),
                const SizedBox(height: AppDimens.dimen8),
                _buildAmountInput(),

                const SizedBox(height: AppDimens.dimen20),

                // 3. Category Selector Dropdown
                _buildLabel('Category'),
                const SizedBox(height: AppDimens.dimen8),
                _buildCategorySelector(),
                if (_categoryError != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _categoryError!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppDimens.dimen20),

                // 4. Date Picker Field
                _buildLabel('Date'),
                const SizedBox(height: AppDimens.dimen8),
                _buildDatePicker(dateFormatted),

                const SizedBox(height: AppDimens.dimen20),

                // 5. Payment Method Dropdown (using PaymentMode enum)
                _buildLabel('Payment Method'),
                const SizedBox(height: AppDimens.dimen8),
                _buildPaymentMethodSelector(),
                if (_paymentMethodError != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _paymentMethodError!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppDimens.dimen20),

                // 6. Note (Optional)
                _buildLabel('Note (Optional)'),
                const SizedBox(height: AppDimens.dimen8),
                _buildNoteInput(),

                const SizedBox(height: AppDimens.dimen36),

                // 7. Gradient Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: AppTextButton(
                    title: isEditing ? 'Save Changes' : 'Save',
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    onPressed: _isSaving ? null : _saveTransaction,
                  ),
                ),

                const SizedBox(height: AppDimens.dimen30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTypeSegmentedToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Expense Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _onTypeChanged(TransactionType.expense),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.expense
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Expense',
                  style: TextStyle(
                    color: _selectedType == TransactionType.expense
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontWeight: _selectedType == TransactionType.expense
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          // Income Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _onTypeChanged(TransactionType.income),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedType == TransactionType.income
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Income',
                  style: TextStyle(
                    color: _selectedType == TransactionType.income
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontWeight: _selectedType == TransactionType.income
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Enter amount',
          hintStyle: const TextStyle(
            color: AppColors.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _currencySymbol,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter an amount';
          }
          final parsed = double.tryParse(value.trim());
          if (parsed == null || parsed <= 0) {
            return 'Please enter a valid amount greater than 0';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    final hasSelection = _selectedCategory != null;

    return InkWell(
      onTap: _isLoading ? null : _showCategoryDropdown,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _categoryError != null
                ? AppColors.expense
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            if (hasSelection)
              Icon(
                _selectedCategory!.iconData,
                color: _selectedCategory!.colorValue,
                size: 22,
              )
            else
              const Icon(
                Icons.work_outline_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                hasSelection ? _selectedCategory!.name : 'Select category',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                  color: hasSelection
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String dateFormatted) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                dateFormatted,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final hasSelection = _selectedPaymentMode != null;

    return InkWell(
      onTap: _showPaymentModeDropdown,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _paymentMethodError != null
                ? AppColors.expense
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasSelection
                  ? _selectedPaymentMode!.icon
                  : Icons.credit_card_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                hasSelection ? _selectedPaymentMode!.displayName : 'Select method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                  color: hasSelection
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextFormField(
        controller: _noteController,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: 'Add note',
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.edit_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
