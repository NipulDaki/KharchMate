import 'package:flutter/material.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_font.dart';
import 'package:kharch_mate/theme/app_colors_extension.dart';
import 'package:kharch_mate/theme/custom_text_style.dart';

class AppThemes {
  // -------------------------------------------------------------
  // LIGHT PALETTE
  // -------------------------------------------------------------
  static const AppColorsExtension lightColorsExtension = AppColorsExtension(
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    primaryDark: AppColors.primaryDark,
    primaryBackground: AppColors.primaryBackground,
    linearGradient: AppColors.linerGradient,
    scaffoldBackground: AppColors.background, // 0xFFFFFAF0
    cardBackground: AppColors.white,
    elevatedSurface: AppColors.white,
    cardBorder: AppColors.borderColor, // 0xFFE2E8EC
    divider: AppColors.dividerColor, // 0xFFF0F2F3
    textPrimary: AppColors.textPrimary, // 0xFF05335B
    textSecondary: AppColors.textSecondary, // 0xFF45627A
    textHint: AppColors.textHint, // 0xFF78909C
    income: AppColors.income, // 0xFF1A6C45
    incomeContainer: AppColors.incomeLight, // 0xFFE8F5EE
    expense: AppColors.expense, // 0xFFF44336
    expenseContainer: AppColors.expenseLight, // 0xFFFFEBEE
    savings: AppColors.savings, // 0xFF00897B
    savingsContainer: AppColors.savingsLight, // 0xFFE0F2F1
    bottomNavBackground: AppColors.white,
    bottomNavSelected: AppColors.bottomNavSelected,
    bottomNavUnselected: AppColors.bottomNavUnselected,
    inputFill: AppColors.primaryBackground,
    inputBorder: AppColors.borderColor,
  );

  // -------------------------------------------------------------
  // DARK PALETTE (Midnight Slate)
  // -------------------------------------------------------------
  static const AppColorsExtension darkColorsExtension = AppColorsExtension(
    primary: Color(0xFFFFA726), // Luminous amber-orange
    primaryLight: Color(0xFFFFCC80),
    primaryDark: Color(0xFFF57C00),
    primaryBackground: Color(0xFF261D12),
    linearGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE65100),
        Color(0xFFF57C00),
        Color(0xFFFFA726),
      ],
    ),
    scaffoldBackground: Color(0xFF0B111E), // Deep midnight slate
    cardBackground: Color(0xFF162032), // Elevated slate surface
    elevatedSurface: Color(0xFF222F46), // High elevation / dialogs
    cardBorder: Color(0xFF26354D), // Muted dark slate border
    divider: Color(0xFF1C2A3F), // Subtle divider
    textPrimary: Color(0xFFF8FAFC), // Slate 50 (95% contrast)
    textSecondary: Color(0xFF94A3B8), // Slate 400 (70% contrast)
    textHint: Color(0xFF64748B), // Slate 500 (45% contrast)
    income: Color(0xFF34D399), // Mint green
    incomeContainer: Color(0xFF062E1F), // Dark mint container
    expense: Color(0xFFF87171), // Soft coral red
    expenseContainer: Color(0xFF3B1717), // Dark wine container
    savings: Color(0xFF2DD4BF), // Bright cyan/teal
    savingsContainer: Color(0xFF0B2C27), // Dark teal container
    bottomNavBackground: Color(0xFF162032),
    bottomNavSelected: Color(0xFFFFA726),
    bottomNavUnselected: Color(0xFF64748B),
    inputFill: Color(0xFF162032),
    inputBorder: Color(0xFF26354D),
  );

  // Light Theme
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    colors: lightColorsExtension,
    primaryColor: lightColorsExtension.primary,
  );

  // Dark Theme
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colors: darkColorsExtension,
    primaryColor: darkColorsExtension.primary,
  );

  // Backward compatibility alias
  static ThemeData get coreTheme => lightTheme;

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorsExtension colors,
    required Color primaryColor,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      fontFamily: AppFonts.poppins,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? const Color(0xFF1C1304) : Colors.white,
        primaryContainer: colors.primaryBackground,
        onPrimaryContainer: isDark ? colors.primaryLight : colors.primaryDark,
        secondary: primaryColor,
        onSecondary: isDark ? const Color(0xFF1C1304) : Colors.white,
        error: colors.expense,
        onError: Colors.white,
        errorContainer: colors.expenseContainer,
        onErrorContainer: colors.expense,
        surface: colors.cardBackground,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.cardBorder,
        outlineVariant: colors.divider,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colors.cardBackground,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
      ),
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.cardBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(color: colors.cardBorder),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      dividerColor: colors.divider,
      hintColor: colors.textHint,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primaryLight.withValues(alpha: 0.3),
        selectionHandleColor: colors.primary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.scaffoldBackground,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: CustomTextStyle.titleLarge.copyWith(
          color: colors.textPrimary,
        ),
      ),
      textTheme: CustomTextStyle.buildTextTheme(colors.textPrimary),
      extensions: [colors],
    );
  }
}
