import 'package:flutter/material.dart';
import 'package:kharch_mate/resources/app_colors.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.borderRadius,
    this.isEnabled = true,
    this.style,
    super.key,
  });

  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isEnabled;
  final ButtonStyle? style;
  //_controller = WidgetStatesController();

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius ?? 6.0);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.linerGradient,
        borderRadius: radius,
      ),
      child: TextButton(
        onPressed: onPressed,
        style:
            style ??
            TextButton.styleFrom(
              foregroundColor: AppColors.white,
              disabledBackgroundColor: Colors.grey.shade600,
              disabledForegroundColor: Colors.grey.shade200,
              textStyle: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: .w600),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
        child: Text(
          title,
          style:
              textStyle ??
              Theme.of(context).textTheme.titleSmall?.copyWith(
                color: onPressed != null
                    ? AppColors.white
                    : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}
