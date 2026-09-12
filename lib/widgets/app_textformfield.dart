import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kharch_mate/resources/app_colors.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    required this.controller,
    this.autoValidate,
    this.obscureText,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.readOnly = false,
    this.adjacentLabelText,

    this.isSuffixEnabled = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLengthEnforcement,
    this.maxLength,
    this.padding,
    this.isEnabled = true,
    this.onFieldSubmitted,
    this.maxHeight,
    this.hasBorder = true,
    this.onValueChanged,
    this.focusNode,
    this.onTapAlwaysCalled = false,
    this.onTap,
    this.fontSize,
    this.expands,
    this.textInputAction,
    this.dismissKeyboardOnTapOutside = true,

    // Newly added customizations
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.errorMaxLines = 2,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.scrollPadding = const EdgeInsets.all(20),
    this.autofillHints,
    this.onEditingComplete,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.showRequiredStar = false,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? adjacentLabelText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? autoValidate;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final bool isSuffixEnabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final EdgeInsetsGeometry? padding;
  final bool isEnabled;
  final bool hasBorder;
  final Function(String?)? onValueChanged;
  final Function(String?)? onFieldSubmitted;
  final double? maxHeight;
  final FocusNode? focusNode;
  final bool onTapAlwaysCalled;
  final VoidCallback? onTap;
  final double? fontSize;
  final bool? expands;
  final TextInputAction? textInputAction;
  final bool dismissKeyboardOnTapOutside;
  final bool showRequiredStar;

  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final FloatingLabelBehavior floatingLabelBehavior;
  final int errorMaxLines;
  final Color? cursorColor;
  final double? cursorHeight;
  final double? cursorWidth;
  final EdgeInsets scrollPadding;
  final Iterable<String>? autofillHints;
  final VoidCallback? onEditingComplete;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: widget.padding ?? EdgeInsets.zero,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.adjacentLabelText != null) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.adjacentLabelText,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (widget.showRequiredStar)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red, // red star
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          obscureText: widget.obscureText ?? false,
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          readOnly: widget.readOnly ? widget.readOnly : !widget.isEnabled,
          enabled: !widget.readOnly ? widget.isEnabled : widget.readOnly,
          focusNode: _focusNode,
          onTapAlwaysCalled: widget.onTapAlwaysCalled,
          onTap: widget.onTap,
          onTapOutside: widget.dismissKeyboardOnTapOutside
              ? (event) => FocusScope.of(context).unfocus()
              : null,

          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          cursorColor: widget.cursorColor,
          cursorHeight: widget.cursorHeight,
          cursorWidth: widget.cursorWidth ?? 2,
          scrollPadding: widget.scrollPadding,
          onEditingComplete: widget.onEditingComplete,

          autovalidateMode: widget.autoValidate ?? false
              ? AutovalidateMode.always
              : AutovalidateMode.onUserInteraction,

          buildCounter: widget.maxLength != null
              ? (
                  context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) {
                  return null;
                }
              : null,

          style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,

          decoration: InputDecoration(
            floatingLabelBehavior: widget.floatingLabelBehavior,
            errorMaxLines: widget.errorMaxLines,
            counterText: "",
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textHint),
            labelText: widget.labelText,
            labelStyle: Theme.of(context).textTheme.bodyMedium,
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints:
                widget.prefixIconConstraints ??
                const BoxConstraints(minWidth: 40),

            suffixIcon: widget.suffixIcon,
            suffixIconConstraints:
                widget.suffixIconConstraints ??
                const BoxConstraints(minWidth: 40),

            isDense: true,
            filled: widget.isEnabled,
            fillColor: widget.isEnabled
                ? AppColors.primaryBackground
                : Colors.grey.shade500,

            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.hasBorder
                    ? AppColors.borderColor
                    : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.hasBorder
                    ? AppColors.primary
                    : Colors.transparent,
                width: widget.hasBorder ? 1 : 0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.hasBorder
                    ? AppColors.bottomNavUnselected
                    : Colors.transparent,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),

            contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
          ),

          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onValueChanged,
        ),
      ],
    ),
  );
}
