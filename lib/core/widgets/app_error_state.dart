import 'package:flutter/material.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../constants/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allXl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsThin.warningCircle,
            size: 32,
            color: AppColors.of(context).error,
          ),
          AppSpacing.gapLg,
          Text('Something went wrong', style: AppTypography.headlineItalic),
          AppSpacing.gapSm,
          Text(
            message ?? AppStrings.eroareNecunoscuta,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.of(context).onSurfaceMuted,
            ),
          ),
          if (onRetry != null) ...[
            AppSpacing.gapLg,
            AppButton(
              label: AppStrings.reincearca,
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
