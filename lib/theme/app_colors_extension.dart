import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Brand
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryBackground;
  final LinearGradient linearGradient;

  // Background & Surfaces
  final Color scaffoldBackground;
  final Color cardBackground;
  final Color elevatedSurface;
  final Color cardBorder;
  final Color divider;

  // Typography
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Financial Semantics
  final Color income;
  final Color incomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color savings;
  final Color savingsContainer;

  // Navigation
  final Color bottomNavBackground;
  final Color bottomNavSelected;
  final Color bottomNavUnselected;

  // Form Inputs
  final Color inputFill;
  final Color inputBorder;

  const AppColorsExtension({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryBackground,
    required this.linearGradient,
    required this.scaffoldBackground,
    required this.cardBackground,
    required this.elevatedSurface,
    required this.cardBorder,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.income,
    required this.incomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.savings,
    required this.savingsContainer,
    required this.bottomNavBackground,
    required this.bottomNavSelected,
    required this.bottomNavUnselected,
    required this.inputFill,
    required this.inputBorder,
  });

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? primaryBackground,
    LinearGradient? linearGradient,
    Color? scaffoldBackground,
    Color? cardBackground,
    Color? elevatedSurface,
    Color? cardBorder,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? income,
    Color? incomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? savings,
    Color? savingsContainer,
    Color? bottomNavBackground,
    Color? bottomNavSelected,
    Color? bottomNavUnselected,
    Color? inputFill,
    Color? inputBorder,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      linearGradient: linearGradient ?? this.linearGradient,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      income: income ?? this.income,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      expense: expense ?? this.expense,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      savings: savings ?? this.savings,
      savingsContainer: savingsContainer ?? this.savingsContainer,
      bottomNavBackground: bottomNavBackground ?? this.bottomNavBackground,
      bottomNavSelected: bottomNavSelected ?? this.bottomNavSelected,
      bottomNavUnselected: bottomNavUnselected ?? this.bottomNavUnselected,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t)!,
      linearGradient: LinearGradient.lerp(linearGradient, other.linearGradient, t)!,
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      income: Color.lerp(income, other.income, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseContainer:
          Color.lerp(expenseContainer, other.expenseContainer, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      savingsContainer:
          Color.lerp(savingsContainer, other.savingsContainer, t)!,
      bottomNavBackground:
          Color.lerp(bottomNavBackground, other.bottomNavBackground, t)!,
      bottomNavSelected:
          Color.lerp(bottomNavSelected, other.bottomNavSelected, t)!,
      bottomNavUnselected:
          Color.lerp(bottomNavUnselected, other.bottomNavUnselected, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
    );
  }
}
