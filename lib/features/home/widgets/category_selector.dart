import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class CategorySelector extends StatefulWidget {
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
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  static const double _cardWidth = 132;
  static const double _separator = AppSpacing.md;
  static const double _leadingPad = AppSpacing.lg;

  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected && widget.selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _centerSelected() {
    if (!_scroll.hasClients || widget.selected == null) return;
    final index = VendorCategory.values.indexOf(widget.selected!);
    final cardCenter =
        _leadingPad + index * (_cardWidth + _separator) + _cardWidth / 2;
    final viewport = _scroll.position.viewportDimension;
    final target = (cardCenter - viewport / 2).clamp(
      _scroll.position.minScrollExtent,
      _scroll.position.maxScrollExtent,
    );
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _leadingPad),
        itemCount: VendorCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: _separator),
        itemBuilder: (context, i) {
          final cat = VendorCategory.values[i];
          final isSelected = cat == widget.selected;
          final count = widget.counts[cat] ?? 0;
          return _CategoryCard(
            category: cat,
            count: count,
            selected: isSelected,
            onTap: () => widget.onSelect(cat),
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
    final fg = selected ? AppColors.of(context).background : AppColors.of(context).onSurface;
    final mutedFg =
        selected ? AppColors.of(context).background.withValues(alpha: 0.7) : AppColors.of(context).onSurfaceMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 132,
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: selected ? AppColors.of(context).primary : AppColors.of(context).surfaceVariant,
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
                  '$count OPTIONS',
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
