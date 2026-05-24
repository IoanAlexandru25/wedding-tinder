import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';

class BudgetSummary extends StatelessWidget {
  const BudgetSummary({
    super.key,
    required this.estimated,
    required this.budgetMax,
  });

  final int estimated;
  final int budgetMax;

  @override
  Widget build(BuildContext context) {
    final ratio = budgetMax == 0 ? 0.0 : (estimated / budgetMax).clamp(0.0, 2.0);
    final overBudget = ratio > 1.0;
    final fillColor = overBudget ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ESTIMARE TOTALĂ',
                style: AppTypography.overline.copyWith(letterSpacing: 1.4),
              ),
              const Spacer(),
              Text(
                Formatters.ron(estimated),
                style: AppTypography.headlineMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: overBudget ? AppColors.error : AppColors.onSurface,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          ClipRRect(
            borderRadius: AppRadii.fullAll,
            child: Stack(
              children: [
                Container(height: 2, color: AppColors.surfaceVariant),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(height: 2, color: fillColor),
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
          Text(
            overBudget
                ? 'Peste bugetul de ${Formatters.ron(budgetMax)} cu ${Formatters.ron(estimated - budgetMax)}.'
                : 'Din ${Formatters.ron(budgetMax)} buget total.',
            style: AppTypography.bodySmall.copyWith(
              color: overBudget ? AppColors.error : AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
