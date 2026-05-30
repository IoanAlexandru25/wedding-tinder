import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../core/widgets/gradient_photo.dart';
import '../../models/favorite.dart';
import '../../models/final_selection.dart';
import '../../models/vendor.dart';
import '../../models/vendor_filters.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/filters_provider.dart';
import '../../providers/final_selections_provider.dart';
import '../../providers/vendors_provider.dart';
import '../../providers/session_provider.dart';
import '../swipe/widgets/vendor_detail_sheet.dart';
import 'widgets/budget_summary.dart';
import 'widgets/favorite_tile.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: vendorsAsync.when(
          loading: () => const AppLoading(),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (allVendors) {
            final vendorById = {for (final v in allVendors) v.id: v};
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LISTA VOASTRĂ',
                        style: AppTypography.overline,
                      ),
                      AppSpacing.gapMd,
                      EditorialHeading(
                        style: AppTypography.displayLarge,
                        spans: const [
                          EditorialSpan('Cei '),
                          EditorialSpan('aleși', italic: true),
                          EditorialSpan('.'),
                        ],
                      ),
                      AppSpacing.gapLg,
                      _EditorialTabs(controller: _tabs),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _FavoritesTab(vendorById: vendorById),
                      _FinalListTab(vendorById: vendorById),
                    ],
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

class _EditorialTabs extends StatelessWidget {
  const _EditorialTabs({required this.controller});
  final TabController controller;

  static const _labels = ['FAVORITE', 'LISTA FINALĂ'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        final t = controller.animation!.value;
        return Row(
          children: [
            for (var i = 0; i < _labels.length; i++)
              _TabLabel(
                label: _labels[i],
                isActive: controller.index == i,
                interpolation: (1 - (t - i).abs()).clamp(0.0, 1.0),
                onTap: () => controller.animateTo(i),
              ),
          ],
        );
      },
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isActive,
    required this.interpolation,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final double interpolation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      AppColors.onSurfaceMuted,
      AppColors.primary,
      interpolation,
    )!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.xl, bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: color,
                letterSpacing: 1.6,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 1,
              width: 28,
              color: color.withValues(alpha: 0.2 + 0.8 * interpolation),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab({required this.vendorById});
  final Map<String, Vendor> vendorById;

  void _swipeCategory(BuildContext context, WidgetRef ref, VendorCategory cat) {
    final filters = ref.read(filtersProvider);
    ref.read(filtersProvider.notifier).state = VendorFilters(
      category: cat,
      judet: filters.judet,
      query: filters.query,
      priceMin: filters.priceMin,
      priceMax: filters.priceMax,
    );
    context.push('/swipe');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(favoritesByCategoryProvider);

    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      children: [
        for (final category in VendorCategory.values)
          _CategorySection(
            category: category,
            favorites: grouped[category] ?? const [],
            vendorById: vendorById,
            onRemove: (id) =>
                ref.read(favoritesProvider.notifier).remove(id),
            onToggleConfirm: (vendor, isConfirmed) {
              HapticFeedback.lightImpact();
              final notifier = ref.read(finalSelectionsProvider.notifier);
              if (isConfirmed) {
                notifier.remove(vendor.id);
              } else {
                notifier.confirm(vendor);
              }
            },
            onTap: (v) => VendorDetailSheet.show(context, v),
            onSwipeCategory: () => _swipeCategory(context, ref, category),
          ),
      ],
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.favorites,
    required this.vendorById,
    required this.onRemove,
    required this.onToggleConfirm,
    required this.onTap,
    required this.onSwipeCategory,
  });

  final VendorCategory category;
  final List<Favorite> favorites;
  final Map<String, Vendor> vendorById;
  final ValueChanged<String> onRemove;
  final void Function(Vendor vendor, bool isConfirmed) onToggleConfirm;
  final ValueChanged<Vendor> onTap;
  final VoidCallback onSwipeCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = favorites
        .map((f) => vendorById[f.vendorId])
        .whereType<Vendor>()
        .toList();
    final isEmpty = vendors.isEmpty;
    final confirmedIds = {
      for (final s in ref.watch(finalSelectionsProvider)) s.vendorId,
    };

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
                    color: isEmpty
                        ? AppColors.onSurfaceMuted
                        : AppColors.onSurface,
                  ),
                ),
                AppSpacing.gapSm,
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    isEmpty
                        ? 'NICIUN ALES'
                        : '${vendors.length} ${vendors.length == 1 ? 'ALES' : 'ALEȘI'}',
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
          if (isEmpty)
            Padding(
              padding: AppSpacing.screenEdge,
              child: _EmptyCategoryCard(
                category: category,
                onTap: onSwipeCategory,
              ),
            )
          else
            SizedBox(
              height: 264,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: vendors.length,
                separatorBuilder: (_, _) => AppSpacing.gapMd,
                itemBuilder: (context, i) {
                  final vendor = vendors[i];
                  final isConfirmed = confirmedIds.contains(vendor.id);
                  return Stack(
                    key: ValueKey(vendor.id),
                    children: [
                      FavoriteTile(
                        vendor: vendor,
                        onTap: () => onTap(vendor),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: _RemoveBadge(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onRemove(vendor.id);
                          },
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: _ConfirmBadge(
                          isConfirmed: isConfirmed,
                          onTap: () => onToggleConfirm(vendor, isConfirmed),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  const _EmptyCategoryCard({required this.category, required this.onTap});
  final VendorCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(category.icon, size: 22, color: AppColors.onSurfaceMuted),
            AppSpacing.gapMd,
            Expanded(
              child: Text(
                'Începe să dai swipe pentru ${category.pluralLabel.toLowerCase()}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
            AppSpacing.gapSm,
            Icon(
              PhosphorIconsThin.arrowRight,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBadge extends StatelessWidget {
  const _ConfirmBadge({required this.isConfirmed, required this.onTap});
  final bool isConfirmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isConfirmed
              ? AppColors.primary
              : AppColors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(
            color: isConfirmed ? AppColors.primary : AppColors.borderStrong,
            width: 1,
          ),
        ),
        child: Icon(
          PhosphorIconsThin.check,
          size: 16,
          color: isConfirmed ? AppColors.onPrimary : AppColors.onSurfaceMuted,
        ),
      ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong, width: 1),
        ),
        child: Icon(
          PhosphorIconsThin.x,
          size: 16,
          color: AppColors.onSurfaceMuted,
        ),
      ),
    );
  }
}

class _FinalListTab extends ConsumerWidget {
  const _FinalListTab({required this.vendorById});
  final Map<String, Vendor> vendorById;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(finalSelectionsProvider);
    final wedding = ref.watch(sessionProvider).wedding;

    if (selections.isEmpty) {
      return Padding(
        padding: AppSpacing.screenEdge,
        child: AppEmptyState(
          italicTitle: 'Nicio alegere finală',
          subtitle:
              'Confirmați un vendor din tab-ul Favorite (✓) pentru a-l adăuga aici cu prețul real negociat.',
          icon: PhosphorIconsThin.checkCircle,
        ),
      );
    }

    final guestCount = wedding?.guestCount ?? 100;
    final total = selections.fold<int>(
      0,
      (sum, s) {
        final v = vendorById[s.vendorId];
        if (v == null) return sum;
        return sum + (s.customPrice ?? vendorMidContribution(v, guestCount));
      },
    );

    final ordered = [
      for (final cat in VendorCategory.values)
        ...selections.where((s) => s.category == cat),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            itemCount: ordered.length,
            separatorBuilder: (_, _) => AppSpacing.gapMd,
            itemBuilder: (context, i) {
              final selection = ordered[i];
              final vendor = vendorById[selection.vendorId];
              if (vendor == null) return const SizedBox.shrink();
              return _FinalSelectionCard(
                selection: selection,
                vendor: vendor,
                onEditPrice: () => _editPrice(context, ref, selection, vendor),
                onRemove: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(finalSelectionsProvider.notifier)
                      .remove(selection.vendorId);
                },
              );
            },
          ),
        ),
        if (wedding != null)
          BudgetSummary(
            estimated: total,
            budgetMax: wedding.budgetMax,
          ),
      ],
    );
  }

  Future<void> _editPrice(
    BuildContext context,
    WidgetRef ref,
    FinalSelection selection,
    Vendor vendor,
  ) async {
    final result = await _PriceInputSheet.show(
      context,
      vendor: vendor,
      initial: selection.customPrice,
    );
    if (result == null) return;
    ref
        .read(finalSelectionsProvider.notifier)
        .updateCustomPrice(selection.vendorId, result.value);
  }
}

class _FinalSelectionCard extends StatelessWidget {
  const _FinalSelectionCard({
    required this.selection,
    required this.vendor,
    required this.onEditPrice,
    required this.onRemove,
  });

  final FinalSelection selection;
  final Vendor vendor;
  final VoidCallback onEditPrice;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasCustom = selection.customPrice != null;
    final priceLabel = hasCustom
        ? Formatters.ron(selection.customPrice!)
        : Formatters.priceRange(
            vendor.priceMin,
            vendor.priceMax,
            vendor.priceUnit,
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.wineShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.wine.withValues(alpha: 0.8),
                        AppColors.peach.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                if (vendor.photos.isNotEmpty)
                  GradientPhoto(
                    assetPath: vendor.photos.first,
                    gradientHeight: 0.0,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vendor.category.displayName.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: AppColors.onSurfaceMuted,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  AppSpacing.gapSm,
                  Row(
                    children: [
                      Icon(
                        hasCustom
                            ? PhosphorIconsThin.tag
                            : PhosphorIconsThin.tagSimple,
                        size: 14,
                        color: hasCustom
                            ? AppColors.primary
                            : AppColors.onSurfaceMuted,
                      ),
                      AppSpacing.gapXs,
                      Flexible(
                        child: Text(
                          priceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: hasCustom
                                ? AppColors.primary
                                : AppColors.onSurfaceMuted,
                            fontWeight: hasCustom
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEditPrice,
                  icon: Icon(
                    PhosphorIconsThin.pencilSimple,
                    size: 20,
                    color: AppColors.onSurfaceMuted,
                  ),
                  tooltip: 'Editează prețul',
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    PhosphorIconsThin.x,
                    size: 20,
                    color: AppColors.onSurfaceMuted,
                  ),
                  tooltip: 'Elimină din lista finală',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSheetResult {
  const _PriceSheetResult(this.value);
  final int? value;
}

class _PriceInputSheet extends StatefulWidget {
  const _PriceInputSheet({required this.vendor, required this.initial});
  final Vendor vendor;
  final int? initial;

  static Future<_PriceSheetResult?> show(
    BuildContext context, {
    required Vendor vendor,
    required int? initial,
  }) {
    return showModalBottomSheet<_PriceSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (_) => _PriceInputSheet(vendor: vendor, initial: initial),
    );
  }

  @override
  State<_PriceInputSheet> createState() => _PriceInputSheetState();
}

class _PriceInputSheetState extends State<_PriceInputSheet> {
  late final TextEditingController _ctl =
      TextEditingController(text: widget.initial?.toString() ?? '');

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _ctl.text.trim().replaceAll('.', '').replaceAll(' ', '');
    if (raw.isEmpty) {
      Navigator.of(context).pop(const _PriceSheetResult(null));
      return;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introdu o sumă validă în RON.')),
      );
      return;
    }
    Navigator.of(context).pop(_PriceSheetResult(parsed));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: AppRadii.fullAll,
              ),
            ),
          ),
          AppSpacing.gapLg,
          Text('PREȚ NEGOCIAT', style: AppTypography.overline),
          AppSpacing.gapSm,
          EditorialHeading(
            style: AppTypography.headlineLarge,
            spans: [
              const EditorialSpan('Cât plătiți pentru '),
              EditorialSpan(widget.vendor.name, italic: true),
              const EditorialSpan('?'),
            ],
          ),
          AppSpacing.gapSm,
          Text(
            'Estimare catalog: ${Formatters.priceRange(widget.vendor.priceMin, widget.vendor.priceMax, widget.vendor.priceUnit)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          AppSpacing.gapLg,
          AppTextField(
            controller: _ctl,
            label: 'Sumă totală (RON)',
            hintText: 'ex. 12000',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          AppSpacing.gapLg,
          AppButton(
            label: 'Salvează',
            onPressed: _submit,
            fullWidth: true,
          ),
          AppSpacing.gapSm,
          Center(
            child: TextButton(
              onPressed: () {
                _ctl.clear();
                Navigator.of(context).pop(const _PriceSheetResult(null));
              },
              child: Text(
                'Revino la estimarea din catalog',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int vendorMidContribution(Vendor v, int guestCount) {
  final mid = ((v.priceMin + v.priceMax) / 2).round();
  if (v.priceUnit.contains('persoană') || v.priceUnit.contains('porție')) {
    return mid * guestCount;
  }
  return mid;
}
