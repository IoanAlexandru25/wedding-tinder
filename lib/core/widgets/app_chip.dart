import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surfaceVariant;
    final fg = selected ? AppColors.onPrimary : AppColors.onSurface;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadii.mdAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 16, color: fg),
              AppSpacing.gapXs,
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
