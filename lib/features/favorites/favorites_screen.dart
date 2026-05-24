import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../models/favorite.dart';
import '../../models/vendor.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/vendors_provider.dart';
import '../swipe/widgets/vendor_detail_sheet.dart';
import 'widgets/budget_summary.dart';
import 'widgets/favorite_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(favoritesByCategoryProvider);
    final favorites = ref.watch(favoritesProvider);
    final wedding = ref.watch(sessionProvider).wedding;
    final vendorsAsync = ref.watch(vendorsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: vendorsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (allVendors) {
            final vendorById = {for (final v in allVendors) v.id: v};
            final estimated = _estimateTotal(favorites, vendorById);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xl,
                      bottom: AppSpacing.lg,
                    ),
                    children: [
                      Padding(
                        padding: AppSpacing.screenEdge,
                        child: Text(
                          'LISTA VOASTRĂ',
                          style: AppTypography.overline,
                        ),
                      ),
                      AppSpacing.gapMd,
                      Padding(
                        padding: AppSpacing.screenEdge,
                        child: EditorialHeading(
                          style: AppTypography.displayLarge,
                          spans: const [
                            EditorialSpan('Cei '),
                            EditorialSpan('aleși', italic: true),
                            EditorialSpan('.'),
                          ],
                        ),
                      ),
                      AppSpacing.gapXl,
                      if (favorites.isEmpty)
                        Padding(
                          padding: AppSpacing.screenEdge,
                          child: AppEmptyState(
                            italicTitle: 'Încă nimic salvat',
                            subtitle:
                                'Începeți să dați swipe pentru a construi lista voastră.',
                            icon: PhosphorIconsThin.heart,
                          ),
                        )
                      else
                        for (final entry in grouped.entries)
                          _CategorySection(
                            category: entry.key,
                            favorites: entry.value,
                            vendorById: vendorById,
                            onRemove: (id) => ref
                                .read(favoritesProvider.notifier)
                                .remove(id),
                            onTap: (v) => VendorDetailSheet.show(context, v),
                          ),
                    ],
                  ),
                ),
                if (favorites.isNotEmpty && wedding != null)
                  BudgetSummary(
                    estimated: estimated,
                    budgetMax: wedding.budgetMax,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static int _estimateTotal(
    List<Favorite> favorites,
    Map<String, Vendor> vendorById,
  ) {
    var total = 0;
    for (final f in favorites) {
      final v = vendorById[f.vendorId];
      if (v == null) continue;
      total += _vendorContribution(v);
    }
    return total;
  }

  static int _vendorContribution(Vendor v) {
    final mid = ((v.priceMin + v.priceMax) / 2).round();
    if (v.priceUnit.contains('persoană') || v.priceUnit.contains('porție')) {
      return mid * 150;
    }
    return mid;
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.favorites,
    required this.vendorById,
    required this.onRemove,
    required this.onTap,
  });

  final VendorCategory category;
  final List<Favorite> favorites;
  final Map<String, Vendor> vendorById;
  final ValueChanged<String> onRemove;
  final ValueChanged<Vendor> onTap;

  @override
  Widget build(BuildContext context) {
    final vendors = favorites
        .map((f) => vendorById[f.vendorId])
        .whereType<Vendor>()
        .toList();
    if (vendors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.screenEdge,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  category.pluralLabel,
                  style: AppTypography.headlineLarge.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                AppSpacing.gapSm,
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${vendors.length} ${vendors.length == 1 ? 'ALES' : 'ALEȘI'}',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.onSurfaceMuted,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: vendors.length,
              separatorBuilder: (_, _) => AppSpacing.gapMd,
              itemBuilder: (context, i) {
                final vendor = vendors[i];
                return Dismissible(
                  key: ValueKey(vendor.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) => onRemove(vendor.id),
                  child: FavoriteTile(
                    vendor: vendor,
                    onTap: () => onTap(vendor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
