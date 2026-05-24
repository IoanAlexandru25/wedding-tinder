import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text, destructive }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(widget.variant, _enabled);
    final showBorder = widget.variant == AppButtonVariant.secondary;
    final isText = widget.variant == AppButtonVariant.text;

    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: isText ? null : 52,
          padding: isText
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                )
              : const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: AppRadii.buttonAll,
            border: showBorder
                ? Border.all(color: colors.foreground, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.foreground,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: colors.foreground),
                      AppSpacing.gapSm,
                    ],
                    Text(
                      widget.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTap: _enabled ? widget.onPressed : null,
      child: widget.fullWidth
          ? SizedBox(width: double.infinity, child: child)
          : child,
    );
  }
}

class _ButtonColors {
  const _ButtonColors(this.background, this.foreground);
  final Color background;
  final Color foreground;
}

_ButtonColors _colorsFor(AppButtonVariant variant, bool enabled) {
  if (!enabled) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return const _ButtonColors(AppColors.disabled, AppColors.onPrimary);
      case AppButtonVariant.secondary:
      case AppButtonVariant.text:
        return const _ButtonColors(Colors.transparent, AppColors.disabled);
    }
  }
  switch (variant) {
    case AppButtonVariant.primary:
      return const _ButtonColors(AppColors.primary, AppColors.onPrimary);
    case AppButtonVariant.secondary:
      return const _ButtonColors(Colors.transparent, AppColors.primary);
    case AppButtonVariant.text:
      return const _ButtonColors(Colors.transparent, AppColors.primary);
    case AppButtonVariant.destructive:
      return const _ButtonColors(AppColors.error, AppColors.onPrimary);
  }
}
