import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/categories.dart';
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
import '../../models/vendor_filters.dart';
import 'widgets/category_selector.dart';
import 'widgets/judet_picker.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wedding = ref.watch(sessionProvider).wedding;
    final user = ref.watch(sessionProvider).user;
    final filters = ref.watch(filtersProvider);
    final countsAsync = ref.watch(vendorCountsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: countsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(vendorCountsProvider),
          ),
          data: (counts) {
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
                      const EditorialSpan('Bună, '),
                      EditorialSpan(
                        user?.displayName ?? 'voi',
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
                    'Alegeți o categorie și începeți să dați swipe.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ),
                AppSpacing.gapXl,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _SectionTitle('Categorii', '01'),
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
                  child: Row(
                    children: [
                      _SectionTitle('Filtre', '02'),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final selected = await JudetPicker.show(
                            context,
                            initial: filters.judet,
                          );
                          if (selected == null) return;
                          ref.read(filtersProvider.notifier).state =
                              VendorFilters(
                            category: filters.category,
                            judet: selected.isEmpty ? null : selected,
                            query: filters.query,
                            priceMin: filters.priceMin,
                            priceMax: filters.priceMax,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsThin.mapPin,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            AppSpacing.gapXs,
                            Text(
                              filters.judet ?? 'TOATE JUDEȚELE',
                              style: AppTypography.overline.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.4,
                              ),
                            ),
                            AppSpacing.gapXs,
                            Icon(
                              PhosphorIconsThin.caretDown,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapLg,
                Padding(
                  padding: AppSpacing.screenEdge,
                  child: _PreviewVendorsAvailable(
                    onStart: () {
                      if (filters.category == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Alege o categorie ca să începi.',
                            ),
                          ),
                        );
                        return;
                      }
                      context.push('/swipe');
                    },
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
      if (guestCount != null) '$guestCount INVITAȚI',
      if (budgetMax != null) '${(budgetMax! / 1000).round()}K RON',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.fullAll,
      ),
      child: Text(
        parts.join('  ·  '),
        style: AppTypography.overline.copyWith(
          color: AppColors.onSurface,
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
        Container(width: 24, height: 1, color: AppColors.borderStrong),
        AppSpacing.gapMd,
        Text(
          title.toUpperCase(),
          style: AppTypography.overline.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }
}

class _PreviewVendorsAvailable extends ConsumerWidget {
  const _PreviewVendorsAvailable({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    final filtered = ref.watch(filteredVendorsProvider);

    final label = filters.category == null
        ? 'Selectează o categorie pentru a începe'
        : '${filtered.length} ${filters.category!.pluralLabel.toLowerCase()} disponibili';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        AppSpacing.gapLg,
        AppButton(
          label: 'Începe să dai swipe',
          icon: PhosphorIconsThin.arrowRight,
          onPressed: onStart,
          fullWidth: true,
        ),
      ],
    );
  }
}
