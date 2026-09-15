import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/resources/app_colors.dart';

enum TransactionType {
  expense,
  income;

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
      default:
        return TransactionType.expense;
    }
  }

  String toDbString() {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
    }
  }

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

class TransactionItem {
  final int? id;
  final String? title;
  final double amount;
  final TransactionType type;
  final int categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final DateTime date;
  final String? note;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionItem({
    this.id,
    this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.paymentMethodId,
    this.paymentMethodName,
    required this.date,
    this.note,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionItem copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    int? paymentMethodId,
    String? paymentMethodName,
    DateTime? date,
    String? note,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    if (categoryName != null && categoryName!.trim().isNotEmpty) {
      return categoryName!.trim();
    }
    return type.isIncome ? 'Income' : 'Expense';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String get formattedDateTime {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  String formattedAmount({String currencySymbol = '₹'}) {
    final formatter = NumberFormat('#,##,###.##');
    final formattedNum = formatter.format(amount);
    if (type == TransactionType.income) {
      return '+ $currencySymbol$formattedNum';
    } else {
      return '- $currencySymbol$formattedNum';
    }
  }

  Color get categoryColorValue {
    if (categoryColor != null) {
      try {
        final hex = categoryColor!.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      } catch (_) {}
    }
    switch ((categoryName ?? '').toLowerCase()) {
      case 'salary':
        return AppColors.income;
      case 'food':
        return AppColors.food;
      case 'rent':
        return AppColors.rent;
      case 'transport':
        return AppColors.transport;
      case 'shopping':
        return AppColors.shopping;
      case 'bills':
        return AppColors.bills;
      default:
        return type.isIncome ? AppColors.income : AppColors.expense;
    }
  }

  IconData get categoryIconData {
    final icon = CategoryModel.iconDataFrom(categoryIcon, categoryName);
    if (icon != Icons.category_rounded) {
      return icon;
    }
    return type.isIncome
        ? Icons.arrow_upward_rounded
        : Icons.receipt_long_rounded;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colTransactionId: id,
      DatabaseConstants.colTransactionTitle: title,
      DatabaseConstants.colTransactionAmount: amount,
      DatabaseConstants.colTransactionType: type.toDbString(),
      DatabaseConstants.colTransactionCategoryId: categoryId,
      DatabaseConstants.colTransactionPaymentMethodId: paymentMethodId,
      DatabaseConstants.colTransactionPaymentMethodName: paymentMethodName,
      DatabaseConstants.colTransactionDate: date.toIso8601String(),
      DatabaseConstants.colTransactionNote: note,
      DatabaseConstants.colTransactionReceiptPath: receiptImagePath,
      DatabaseConstants.colTransactionCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colTransactionUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map[DatabaseConstants.colTransactionId] as int?,
      title: map[DatabaseConstants.colTransactionTitle] as String?,
      amount: (map[DatabaseConstants.colTransactionAmount] as num?)?.toDouble() ??
          0.0,
      type: TransactionType.fromString(
        map[DatabaseConstants.colTransactionType] as String? ?? 'expense',
      ),
      categoryId:
          map[DatabaseConstants.colTransactionCategoryId] as int? ?? 0,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
      paymentMethodId:
          map[DatabaseConstants.colTransactionPaymentMethodId] as int?,
      paymentMethodName:
          map[DatabaseConstants.colTransactionPaymentMethodName] as String?,
      date: DateTime.tryParse(
            map[DatabaseConstants.colTransactionDate] as String? ?? '',
          ) ??
          DateTime.now(),
      note: map[DatabaseConstants.colTransactionNote] as String?,
      receiptImagePath:
          map[DatabaseConstants.colTransactionReceiptPath] as String?,
      createdAt: DateTime.tryParse(
            map[DatabaseConstants.colTransactionCreatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map[DatabaseConstants.colTransactionUpdatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
