import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

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
  const VendorDetailSheet({
    super.key,
    required this.vendor,
    this.onAddedFromSwipe,
  });

  final Vendor vendor;
  final VoidCallback? onAddedFromSwipe;

  static Future<void> show(
    BuildContext context,
    Vendor vendor, {
    VoidCallback? onAddedFromSwipe,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => VendorDetailSheet(
        vendor: vendor,
        onAddedFromSwipe: onAddedFromSwipe,
      ),
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
                        '· ${vendor.reviewCount} reviews',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  AppSpacing.gapLg,
                  Text(vendor.description, style: AppTypography.bodyLarge),
                  AppSpacing.gapXl,
                  _MetaRow(
                    label: 'PRICE',
                    value: Formatters.priceRange(
                      vendor.priceMin,
                      vendor.priceMax,
                      vendor.priceUnit,
                    ),
                  ),
                  _MetaRow(label: 'COUNTY', value: vendor.judet),
                  if (vendor.phone != null)
                    _MetaRow(label: 'PHONE', value: vendor.phone!),
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
                        ? 'Remove from favorites'
                        : 'Add to favorites',
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
                        return;
                      }
                      if (onAddedFromSwipe != null) {
                        Navigator.of(context).pop();
                        onAddedFromSwipe!();
                        return;
                      }
                      if (user != null) {
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

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photos});
  final List<String> photos;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final PageController _ctl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        height: 240,
        color: AppColors.surfaceVariant,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.disabled),
      );
    }
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctl,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => _openFullscreen(context, i),
                child: Stack(
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
                    GradientPhoto(
                      assetPath: widget.photos[i],
                      gradientHeight: 0.4,
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.md,
              child: _PageDots(
                count: widget.photos.length,
                index: _index,
              ),
            ),
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsThin.arrowsOutSimple,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: _FullscreenGallery(
              photos: widget.photos,
              initialIndex: initialIndex,
            ),
          );
        },
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: AppRadii.fullAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                width: i == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: AppRadii.fullAll,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({
    required this.photos,
    required this.initialIndex,
  });
  final List<String> photos;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _ctl =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _ctl,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final photo = widget.photos[i];
                final isNetwork = photo.startsWith('http');
                const errorWidget = Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                );
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: isNetwork
                        ? Image.network(
                            photo,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white54,
                                        ),
                                      ),
                            errorBuilder: (context, error, stack) =>
                                errorWidget,
                          )
                        : Image.asset(
                            photo,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                errorWidget,
                          ),
                  ),
                );
              },
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _CircleIconButton(
                icon: PhosphorIconsThin.x,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            if (widget.photos.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.lg,
                child: Column(
                  children: [
                    _PageDots(count: widget.photos.length, index: _index),
                    AppSpacing.gapSm,
                    Text(
                      '${_index + 1} / ${widget.photos.length}',
                      style: AppTypography.overline.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          PhosphorIconsThin.x,
          color: Colors.white,
          size: 22,
        ),
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
