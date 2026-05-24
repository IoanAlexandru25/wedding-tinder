import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  final VendorCategory? selected;
  final Map<VendorCategory, int> counts;
  final ValueChanged<VendorCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: VendorCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final cat = VendorCategory.values[i];
          final isSelected = cat == selected;
          final count = counts[cat] ?? 0;
          return _CategoryCard(
            category: cat,
            count: count,
            selected: isSelected,
            onTap: () => onSelect(cat),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final VendorCategory category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.background : AppColors.onSurface;
    final mutedFg =
        selected ? AppColors.background.withValues(alpha: 0.7) : AppColors.onSurfaceMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 132,
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppRadii.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(category.icon, size: 26, color: fg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.pluralLabel,
                  style: AppTypography.headlineSmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: fg,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  '$count OPȚIUNI',
                  style: AppTypography.overline.copyWith(color: mutedFg),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
