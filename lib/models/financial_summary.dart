import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kharch_mate/models/category.dart';

class CategorySpending {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final double percentage; // 0.0 to 100.0

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
  });

  Color get colorValue {
    try {
      final hex = categoryColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return Colors.grey;
  }

  IconData get iconData => CategoryModel.iconDataFrom(categoryIcon, categoryName);

  String formattedAmount({String symbol = '₹'}) {
    return '$symbol${NumberFormat('#,##,###').format(amount)}';
  }

  String get formattedPercentage => '${percentage.toStringAsFixed(0)}%';
}

class MonthlyTrend {
  final int month;
  final int year;
  final String monthLabel; // 'Apr', 'May', 'Jun', etc.
  final double income;
  final double expense;

  const MonthlyTrend({
    required this.month,
    required this.year,
    required this.monthLabel,
    required this.income,
    required this.expense,
  });

  double get netSavings => income - expense;
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final double savings;
  final double savingsRate; // 0.0 to 100.0
  final List<CategorySpending> categoryBreakdown;
  final List<MonthlyTrend> monthlyTrends;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.savings,
    required this.savingsRate,
    this.categoryBreakdown = const [],
    this.monthlyTrends = const [],
  });

  factory FinancialSummary.empty() {
    return const FinancialSummary(
      totalIncome: 0.0,
      totalExpense: 0.0,
      totalBalance: 0.0,
      savings: 0.0,
      savingsRate: 0.0,
      categoryBreakdown: [],
      monthlyTrends: [],
    );
  }

  String formattedIncome({String symbol = '₹'}) =>
      '$symbol${NumberFormat('#,##,###').format(totalIncome)}';

  String formattedExpense({String symbol = '₹'}) =>
      '$symbol${NumberFormat('#,##,###').format(totalExpense)}';

  String formattedBalance({String symbol = '₹'}) =>
      '$symbol${NumberFormat('#,##,###').format(totalBalance)}';

  String formattedSavings({String symbol = '₹'}) =>
      '$symbol${NumberFormat('#,##,###').format(savings)}';

  String get formattedSavingsRate => '${savingsRate.toStringAsFixed(0)}%';
}
