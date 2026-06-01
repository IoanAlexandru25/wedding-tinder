import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../providers/filters_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/vendors_provider.dart';
import 'widgets/category_selector.dart';
import 'widgets/judet_picker.dart';
import 'widgets/price_picker.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wedding = ref.watch(sessionProvider).wedding;
    final user = ref.watch(sessionProvider).user;
    final filters = ref.watch(filtersProvider);
    final vendorsAsync = ref.watch(vendorsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: vendorsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(vendorsProvider),
          ),
          data: (_) {
            final counts = ref.watch(filteredCategoryCountsProvider);
            return ListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.huge,
              ),
              children: [
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _WeddingInfoChip(
                    dateLabel: wedding == null
                        ? '—'
                        : Formatters.shortDateRangeUpper(
                            wedding.weddingDateStart,
                            wedding.weddingDateEnd,
                          ),
                    guestCount: wedding?.guestCount,
                    budgetMax: wedding?.budgetMax,
                  ),
                ),
                AppSpacing.gapXl,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: EditorialHeading(
                    style: AppTypography.displayLarge,
                    spans: [
                      const EditorialSpan('Hello, '),
                      EditorialSpan(
                        user?.displayName ?? 'you',
                        italic: true,
                      ),
                      const EditorialSpan('.'),
                    ],
                  ),
                ),
                AppSpacing.gapMd,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: Text(
                    'Pick a category and start swiping.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.of(context).onSurfaceMuted,
                    ),
                  ),
                ),
                AppSpacing.gapXl,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _SectionTitle('Categories', '01'),
                ),
                AppSpacing.gapLg,
                CategorySelector(
                  selected: filters.category,
                  counts: counts,
                  onSelect: (cat) {
                    ref.read(filtersProvider.notifier).state =
                        filters.copyWith(category: cat);
                  },
                ),
                AppSpacing.gapXl,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _SectionTitle('Filters', '02'),
                ),
                AppSpacing.gapMd,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _FilterPill(
                        icon: PhosphorIconsThin.mapPin,
                        label: filters.judet ?? 'ALL COUNTIES',
                        active: filters.judet != null,
                        onTap: () async {
                          final selected = await JudetPicker.show(
                            context,
                            initial: filters.judet,
                          );
                          if (selected == null) return;
                          ref.read(filtersProvider.notifier).state =
                              filters.copyWith(
                            judet: selected.isEmpty ? null : selected,
                          ).clear(judet: selected.isEmpty);
                        },
                      ),
                      _FilterPill(
                        icon: PhosphorIconsThin.tag,
                        label: _priceLabel(
                          filters.priceMin,
                          filters.priceMax,
                        ),
                        active: filters.priceMin != null ||
                            filters.priceMax != null,
                        onTap: () async {
                          final range = await PricePicker.show(
                            context,
                            initialMin: filters.priceMin,
                            initialMax: filters.priceMax,
                          );
                          if (range == null) return;
                          ref.read(filtersProvider.notifier).state =
                              filters
                                  .copyWith(
                                    priceMin: range.min,
                                    priceMax: range.max,
                                  )
                                  .clear(
                                    price: range.min == null && range.max == null,
                                  );
                        },
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapLg,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _StartSwipeButton(
                    onStart: filters.category == null
                        ? null
                        : () => context.push('/swipe'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WeddingInfoChip extends StatelessWidget {
  const _WeddingInfoChip({
    required this.dateLabel,
    required this.guestCount,
    required this.budgetMax,
  });

  final String dateLabel;
  final int? guestCount;
  final int? budgetMax;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      dateLabel,
      if (guestCount != null) '$guestCount GUESTS',
      if (budgetMax != null) '${(budgetMax! / 1000).round()}K RON',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceVariant,
        borderRadius: AppRadii.fullAll,
      ),
      child: Text(
        parts.join('  ·  '),
        style: AppTypography.overline.copyWith(
          color: AppColors.of(context).onSurface,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.number);
  final String title;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(number, style: AppTypography.overline),
        AppSpacing.gapMd,
        Container(width: 24, height: 1, color: AppColors.of(context).borderStrong),
        AppSpacing.gapMd,
        Text(
          title.toUpperCase(),
          style: AppTypography.overline.copyWith(color: AppColors.of(context).onSurface),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = active ? c.onPrimary : c.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: active ? c.primary : c.surface,
          borderRadius: AppRadii.fullAll,
          border: Border.all(
            color: active ? c.primary : c.borderStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            AppSpacing.gapXs,
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: fg,
                letterSpacing: 1.4,
              ),
            ),
            AppSpacing.gapXs,
            Icon(PhosphorIconsThin.caretDown, size: 12, color: fg),
          ],
        ),
      ),
    );
  }
}

String _priceLabel(int? min, int? max) {
  if (min == null && max == null) return 'ANY PRICE';
  if (min == null) return 'UP TO ${Formatters.ron(max!).toUpperCase()}';
  if (max == null) return 'FROM ${Formatters.ron(min).toUpperCase()}';
  return '${Formatters.ron(min).toUpperCase()} – ${Formatters.ron(max).toUpperCase()}';
}

class _StartSwipeButton extends StatelessWidget {
  const _StartSwipeButton({required this.onStart});
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Start swiping',
      icon: PhosphorIconsThin.arrowRight,
      onPressed: onStart,
      fullWidth: true,
    );
  }
}
