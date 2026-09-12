import 'package:flutter/material.dart';

import 'package:kharch_mate/resources/app_colors.dart';
import 'package:kharch_mate/resources/app_dimension.dart';
import 'package:kharch_mate/resources/app_font.dart';

class CustomTextStyle {
  CustomTextStyle._();
  static TextStyle buttonTextStyleWithPrimary = const TextStyle(
    fontFamily: AppFonts.poppins,
    color: AppColors.textPrimary,
    fontSize: AppDimens.defaultSemiboldTextSize,
    fontWeight: FontWeight.w400,
  );

  static TextStyle buttonTextStyleWithWhite = const TextStyle(
    fontFamily: AppFonts.poppins,
    color: AppColors.textPrimary,
    fontSize: AppDimens.defaultSemiboldTextSize,
    fontWeight: FontWeight.w400,
  );

  static const errorToaseFont = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: AppDimens.dimen14,
  );

  // DISPLAY
  static const TextStyle displayLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen57,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // HEADLINE
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // TITLE
  static const TextStyle titleLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // BODY
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // LABEL (Buttons, chips)

  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: AppDimens.dimen14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
