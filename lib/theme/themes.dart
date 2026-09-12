import 'package:flutter/material.dart';
import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_font.dart';
import 'package:kharch_mate/theme/custom_text_style.dart';

class AppThemes {
  static ThemeData coreTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    fontFamily: AppFonts.poppins,
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
