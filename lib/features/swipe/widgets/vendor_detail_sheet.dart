import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/editorial_heading.dart';
import '../../../core/widgets/gradient_photo.dart';
import '../../../models/vendor.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/session_provider.dart';

class VendorDetailSheet extends ConsumerWidget {
  const VendorDetailSheet({super.key, required this.vendor});

  final Vendor vendor;

  static Future<void> show(BuildContext context, Vendor vendor) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => VendorDetailSheet(vendor: vendor),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      favoritesProvider.select((favs) => favs.any((f) => f.vendorId == vendor.id)),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtl) {
        return ListView(
          controller: scrollCtl,
          padding: EdgeInsets.zero,
          children: [
            _PhotoCarousel(photos: vendor.photos),
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppRadii.fullAll,
                      ),
                    ),
                  ),
                  Text(
                    '${vendor.category.displayName.toUpperCase()} · ${vendor.localitate.toUpperCase()}',
                    style: AppTypography.overline.copyWith(letterSpacing: 1.6),
                  ),
                  AppSpacing.gapSm,
                  EditorialHeading(
                    style: AppTypography.displayMedium,
                    spans: _italicLead(vendor.name),
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.brass),
                      const SizedBox(width: 4),
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: AppTypography.titleSmall,
                      ),
                      AppSpacing.gapXs,
                      Text(
                        '· ${vendor.reviewCount} recenzii',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  AppSpacing.gapLg,
                  Text(vendor.description, style: AppTypography.bodyLarge),
                  AppSpacing.gapXl,
                  _MetaRow(
                    label: 'PREȚ',
                    value: Formatters.priceRange(
                      vendor.priceMin,
                      vendor.priceMax,
                      vendor.priceUnit,
                    ),
                  ),
                  _MetaRow(label: 'JUDEȚ', value: vendor.judet),
                  if (vendor.phone != null)
                    _MetaRow(label: 'TELEFON', value: vendor.phone!),
                  if (vendor.website != null)
                    _MetaRow(label: 'WEBSITE', value: vendor.website!),
                  if (vendor.instagram != null)
                    _MetaRow(label: 'INSTAGRAM', value: vendor.instagram!),
                  AppSpacing.gapLg,
                  if (vendor.tags.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final t in vendor.tags) AppChip(label: t),
                      ],
                    ),
                  AppSpacing.gapXl,
                  AppButton(
                    label: isFav
                        ? 'Elimină din favorite'
                        : 'Adaugă la favorite',
                    icon: isFav
                        ? PhosphorIconsThin.heartBreak
                        : PhosphorIconsThin.heart,
                    variant: isFav
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.primary,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final user = ref.read(sessionProvider).user;
                      final favs = ref.read(favoritesProvider.notifier);
                      if (isFav) {
                        favs.remove(vendor.id);
                      } else if (user != null) {
                        favs.like(vendor, addedBy: user.id);
                      }
                    },
                    fullWidth: true,
                  ),
                  AppSpacing.gapMd,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static List<EditorialSpan> _italicLead(String name) {
    final words = name.split(' ');
    if (words.length == 1) return [EditorialSpan(words.first)];
    return [
      EditorialSpan('${words.first} ', italic: true),
      EditorialSpan(words.skip(1).join(' ')),
    ];
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({required this.photos});
  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 240,
        color: AppColors.surfaceVariant,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.disabled),
      );
    }
    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, i) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.wine.withValues(alpha: 0.7),
                      AppColors.peach.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              GradientPhoto(assetPath: photos[i], gradientHeight: 0.4),
            ],
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTypography.overline.copyWith(letterSpacing: 1.4),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
