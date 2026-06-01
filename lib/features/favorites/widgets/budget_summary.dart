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
    final c = AppColors.of(context);
    final ratio = budgetMax == 0 ? 0.0 : (estimated / budgetMax).clamp(0.0, 2.0);
    final overBudget = ratio > 1.0;
    final fillColor = overBudget ? c.error : c.primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL ESTIMATE',
                style: AppTypography.overline.copyWith(letterSpacing: 1.4),
              ),
              const Spacer(),
              Text(
                Formatters.ron(estimated),
                style: AppTypography.headlineMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: overBudget ? c.error : c.onSurface,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          ClipRRect(
            borderRadius: AppRadii.fullAll,
            child: Stack(
              children: [
                Container(height: 2, color: c.surfaceVariant),
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
                ? 'Over the ${Formatters.ron(budgetMax)} budget by ${Formatters.ron(estimated - budgetMax)}.'
                : 'of ${Formatters.ron(budgetMax)} total budget.',
            style: AppTypography.bodySmall.copyWith(
              color: overBudget ? c.error : c.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
