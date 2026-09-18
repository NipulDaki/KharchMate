import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kharch_mate/di/service_locator.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/router/app_routes.dart';
import 'package:kharch_mate/services/database_service.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionItem? transaction;
  final int? transactionId;

  const TransactionDetailsScreen({
    super.key,
    this.transaction,
    this.transactionId,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late final DatabaseService _dbService;

  TransactionItem? _transaction;
  bool _isLoading = false;
  bool _wasModified = false;
  String _currencySymbol = '₹';

  @override
  void initState() {
    super.initState();
    _dbService = serviceLocator<DatabaseService>();
    _transaction = widget.transaction;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _dbService.getUserProfile();
      if (user != null && user.currencySymbol.isNotEmpty) {
        if (mounted) {
          setState(() => _currencySymbol = user.currencySymbol);
        }
      }

      if (_transaction == null && widget.transactionId != null) {
        setState(() => _isLoading = true);
        final item = await _dbService.getTransactionById(widget.transactionId!);
        if (mounted) {
          setState(() {
            _transaction = item;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (_transaction == null) return;

    final result = await context.push<dynamic>(
      AppRoutes.addTransaction.path,
      extra: _transaction,
    );

    if (result is TransactionItem) {
      setState(() {
        _transaction = result;
        _wasModified = true;
      });
    } else if (result == true) {
      _wasModified = true;
      if (_transaction?.id != null) {
        final reloaded = await _dbService.getTransactionById(_transaction!.id!);
        if (mounted && reloaded != null) {
          setState(() => _transaction = reloaded);
        }
      }
    }
  }

  Future<void> _confirmDelete() async {
    if (_transaction?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Transaction',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
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

    if (confirmed == true && mounted) {
      try {
        await _dbService.deleteTransaction(_transaction!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: AppColors.textPrimary,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete transaction'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_wasModified ? true : null);
    } else {
      context.go(AppRoutes.transaction.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_transaction == null) {
      if (_isLoading) {
        return const Scaffold(
          backgroundColor: AppColors.background,
        );
      }
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
            onPressed: _handleBack,
          ),
          title: const Text(
            'Transaction Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Transaction not found',
            style: TextStyle(color: AppColors.textHint, fontSize: 16),
          ),
        ),
      );
    }

    final tx = _transaction!;
    final isIncome = tx.type.isIncome;
    final amountFormatted = tx.formattedAmount(currencySymbol: _currencySymbol);
    final subtitle = tx.note != null && tx.note!.isNotEmpty
        ? tx.note!
        : (isIncome ? 'Income' : 'Expense');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // PopScope callback
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: _handleBack,
          ),
          title: Text(
            'Transaction Details',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              tooltip: 'Edit Transaction',
              onPressed: _navigateToEdit,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.dimen24,
              vertical: AppDimens.dimen16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.dimen8),

                // 1. Category Header: Circle Icon Badge + Category Name + Subtitle
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: tx.categoryColorValue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tx.categoryIconData,
                        size: 34,
                        color: tx.categoryColorValue,
                      ),
                    ),
                    const SizedBox(width: AppDimens.dimen16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.displayTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.dimen28),

                // 2. Formatted Amount Display
                Text(
                  amountFormatted,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isIncome ? AppColors.income : AppColors.expense,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppDimens.dimen28),

                // 3. Details Section Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.dimen16,
                    vertical: AppDimens.dimen12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      // Date & Time Row
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        title: null,
                        value: tx.formattedDateTime,
                      ),
                      const Divider(
                        height: 24,
                        thickness: 1,
                        color: AppColors.dividerColor,
                      ),
                      // Payment Method Row
                      _buildDetailRow(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Method',
                        value: tx.paymentMethodName ?? 'Cash',
                      ),
                      const Divider(
                        height: 24,
                        thickness: 1,
                        color: AppColors.dividerColor,
                      ),
                      // Note Row
                      _buildDetailRow(
                        icon: Icons.sticky_note_2_outlined,
                        title: 'Note',
                        value: tx.note?.isNotEmpty == true
                            ? tx.note!
                            : 'No note added',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 4. Action Buttons: Edit (Orange Outline) and Delete (Red Outline)
                Row(
                  children: [
                    // Edit Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: AppColors.white,
                          ),
                          onPressed: _navigateToEdit,
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.dimen16),
                    // Delete Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.expense,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: AppColors.white,
                          ),
                          onPressed: _confirmDelete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.expense,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimens.dimen20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String? title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: title != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
