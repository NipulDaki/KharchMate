import 'package:flutter/material.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_font.dart';
import 'package:kharch_mate/theme/custom_text_style.dart';

class AppThemes {
  static ThemeData coreTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    fontFamily: AppFonts.poppins,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.white,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.white,
      surfaceContainer: AppColors.white,
      surfaceContainerHigh: AppColors.white,
      surfaceContainerHighest: AppColors.white,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
    ),
    dividerColor: AppColors.dividerColor,
    hintColor: AppColors.textHint,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryLight,
      selectionHandleColor: AppColors.primaryLight,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.primaryBackground,
    ),
    textTheme: TextTheme(
      displayLarge: CustomTextStyle.displayLarge,
      displayMedium: CustomTextStyle.displayMedium,
      displaySmall: CustomTextStyle.displaySmall,
      headlineLarge: CustomTextStyle.headlineLarge,
      headlineMedium: CustomTextStyle.headlineMedium,
      headlineSmall: CustomTextStyle.headlineSmall,
      titleLarge: CustomTextStyle.titleLarge,
      titleMedium: CustomTextStyle.titleMedium,
      titleSmall: CustomTextStyle.titleSmall,
      bodyLarge: CustomTextStyle.bodyLarge,
      bodyMedium: CustomTextStyle.bodyMedium,
      bodySmall: CustomTextStyle.bodySmall,
      labelLarge: CustomTextStyle.labelLarge,
      labelMedium: CustomTextStyle.labelMedium,
      labelSmall: CustomTextStyle.bodySmall,
    ),

    //typography: Typography()
  );
}
