import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.helperText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? helperText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      style: AppTypography.bodyLarge,
      cursorColor: AppColors.primary,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        labelText: label.toUpperCase(),
        hintText: hintText,
        helperText: helperText,
        helperStyle: AppTypography.labelSmall,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.onSurfaceMuted,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(prefixIcon, size: 20, color: AppColors.onSurfaceMuted),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
