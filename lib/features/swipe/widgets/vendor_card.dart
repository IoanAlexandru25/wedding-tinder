import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/editorial_heading.dart';
import '../../../core/widgets/gradient_photo.dart';
import '../../../models/vendor.dart';

class VendorCard extends StatelessWidget {
  const VendorCard({super.key, required this.vendor, this.onTap});

  final Vendor vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nameWords = vendor.name.split(' ');
    final spans = _italicLeadSpans(nameWords);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardAll,
          boxShadow: [
            BoxShadow(
              color: AppColors.wineShadow,
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.wine.withValues(alpha: 0.85),
                    AppColors.peach.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            if (vendor.photos.isNotEmpty)
              GradientPhoto(
                assetPath: vendor.photos.first,
                gradientHeight: 0.55,
              )
            else
              const _DarkOverlay(),
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${vendor.category.displayName.toUpperCase()} · ${vendor.localitate.toUpperCase()}',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.background.withValues(alpha: 0.85),
                      letterSpacing: 1.6,
                    ),
                  ),
                  AppSpacing.gapSm,
                  EditorialHeading(
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.background,
                      height: 1.0,
                    ),
                    spans: spans,
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      _Pill(
                        text: Formatters.priceRange(
                          vendor.priceMin,
                          vendor.priceMax,
                          vendor.priceUnit,
                        ),
                      ),
                      AppSpacing.gapSm,
                      _RatingChip(rating: vendor.rating),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<EditorialSpan> _italicLeadSpans(List<String> words) {
    if (words.length == 1) {
      return [EditorialSpan(words.first)];
    }
    return [
      EditorialSpan('${words.first} ', italic: true),
      EditorialSpan(words.skip(1).join(' ')),
    ];
  }
}

class _DarkOverlay extends StatelessWidget {
  const _DarkOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.overlayDark],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: AppRadii.smAll,
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(color: AppColors.background),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: AppColors.brass),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.labelSmall.copyWith(color: AppColors.background),
        ),
      ],
    );
  }
}
