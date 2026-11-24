import 'package:flutter/material.dart';
import 'package:kharch_mate/theme/app_colors_extension.dart';
import 'package:kharch_mate/theme/themes.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  AppColorsExtension get colors =>
      theme.extension<AppColorsExtension>() ?? AppThemes.lightColorsExtension;
}
