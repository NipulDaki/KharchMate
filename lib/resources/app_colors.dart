import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFFF57C00);
  static const primaryDark = Color(0xFFE65100);
  static const primaryLight = Color(0xFFFFB74D);
  static const primaryBackground = Color(0xFFFFF3E0);

  // Background
  static const background = Color(0xFFFFFAF0);
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  static const borderColor = Color(0xFFE2E8EC);
  static const dividerColor = Color(0xFFF0F2F3);

  static const bottomNavSelected = Color(0xFFF57C00);
  static const bottomNavUnselected = Color(0xFF8A98A6);

  // Text
  static const textPrimary = Color(0xFF05335B);
  static const textSecondary = Color(0xFF45627A);
  static const textHint = Color(0xFF78909C);

  // Border
  static const border = Color(0xFFE5E5E5);

  // Finance
  static const income = Color(0xFF1A6C45);
  static const incomeLight = Color(0xFFE8F5EE);

  static const expense = Color(0xFFF44336);
  static const expenseLight = Color(0xFFFFEBEE);

  static const savings = Color(0xFF00897B);
  static const savingsLight = Color(0xFFE0F2F1);

  // Categories
  static const food = Color(0xFFFF9800);
  static const shopping = Color(0xFF7E57C2);
  static const transport = Color(0xFF42A5F5);
  static const rent = Color(0xFF26A69A);
  static const other = Color(0xFF66BB6A);
  static const bills = Color(0xFFEF5350);

  static const LinearGradient linerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE65100), // Dark Saffron
      Color(0xFFF57C00), // Saffron
      Color(0xFFFF9800), // Light Orange
    ],
  );
}
