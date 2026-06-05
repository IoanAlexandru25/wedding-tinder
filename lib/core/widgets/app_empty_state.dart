import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.italicTitle,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String italicTitle;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allXl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 32, color: AppColors.of(context).onSurfaceMuted),
            AppSpacing.gapLg,
          ],
          Text(italicTitle, style: AppTypography.headlineItalic),
          if (subtitle != null) ...[
            AppSpacing.gapSm,
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.of(context).onSurfaceMuted,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.gapLg,
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
