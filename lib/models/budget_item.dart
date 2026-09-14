import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/category.dart';

class BudgetItem {
  final int? id;
  final int? categoryId; // null or 0 for overall monthly budget
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final bool isOverall;
  final double amountLimit;
  final double spentAmount;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetItem({
    this.id,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.isOverall = false,
    required this.amountLimit,
    this.spentAmount = 0.0,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetItem copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    bool? isOverall,
    double? amountLimit,
    double? spentAmount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      isOverall: isOverall ?? this.isOverall,
      amountLimit: amountLimit ?? this.amountLimit,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get remainingAmount => (amountLimit - spentAmount).clamp(0.0, double.infinity);

  double get spentPercentage {
    if (amountLimit <= 0) return 0.0;
    return (spentAmount / amountLimit).clamp(0.0, 1.0);
  }

  int get spentPercentageInt => (spentPercentage * 100).round();

  bool get isNearLimit => spentPercentage >= 0.8 && spentPercentage < 1.0;
  bool get isExceeded => spentAmount > amountLimit;

  String formattedLimit({String symbol = '₹'}) {
    return '$symbol${NumberFormat('#,##,###').format(amountLimit)}';
  }

  String formattedSpent({String symbol = '₹'}) {
    return '$symbol${NumberFormat('#,##,###').format(spentAmount)}';
  }

  String formattedRemaining({String symbol = '₹'}) {
    return '$symbol${NumberFormat('#,##,###').format(remainingAmount)}';
  }

  Color get categoryColorValue {
    if (categoryColor == null) return const Color(0xFFF57C00);
    try {
      final hex = categoryColor!.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return const Color(0xFFF57C00);
  }

  IconData get categoryIconData =>
      CategoryModel.iconDataFrom(categoryIcon, categoryName);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colBudgetId: id,
      DatabaseConstants.colBudgetCategoryId: categoryId,
      DatabaseConstants.colBudgetIsOverall: isOverall ? 1 : 0,
      DatabaseConstants.colBudgetAmountLimit: amountLimit,
      DatabaseConstants.colBudgetMonth: month,
      DatabaseConstants.colBudgetYear: year,
      DatabaseConstants.colBudgetCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colBudgetUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory BudgetItem.fromMap(Map<String, dynamic> map) {
    return BudgetItem(
      id: map[DatabaseConstants.colBudgetId] as int?,
      categoryId: map[DatabaseConstants.colBudgetCategoryId] as int?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
      isOverall: (map[DatabaseConstants.colBudgetIsOverall] as int? ?? 0) == 1,
      amountLimit:
          (map[DatabaseConstants.colBudgetAmountLimit] as num?)?.toDouble() ??
              0.0,
      spentAmount: (map['spent_amount'] as num?)?.toDouble() ?? 0.0,
      month: map[DatabaseConstants.colBudgetMonth] as int? ?? 1,
      year: map[DatabaseConstants.colBudgetYear] as int? ?? DateTime.now().year,
      createdAt: DateTime.tryParse(
            map[DatabaseConstants.colBudgetCreatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map[DatabaseConstants.colBudgetUpdatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
