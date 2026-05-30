import 'package:appinio_swiper/appinio_swiper.dart';
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
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../models/vendor.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/filters_provider.dart';
import '../../providers/seen_in_session_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/vendors_provider.dart';
import 'widgets/vendor_card.dart';
import 'widgets/vendor_detail_sheet.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final _controller = AppinioSwiperController();
  late List<Vendor> _stack;

  @override
  void initState() {
    super.initState();
    _stack = ref.read(filteredVendorsProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeEnd(int prev, int target, SwiperActivity activity) {
    if (activity is! Swipe) return;
    final vendor = _stack[prev];
    ref.read(seenInSessionProvider.notifier).markSeen(vendor.id);

    if (activity.direction == AxisDirection.right) {
      final user = ref.read(sessionProvider).user;
      if (user != null) {
        ref.read(favoritesProvider.notifier).like(vendor, addedBy: user.id);
      }
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filtersProvider);
    final categoryLabel = filters.category?.pluralLabel ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(category: categoryLabel),
            Expanded(
              child: _stack.isEmpty
                  ? _EmptyDeck(
                      onChangeCategory: () => context.pop(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: AppinioSwiper(
                        controller: _controller,
                        cardCount: _stack.length,
                        backgroundCardCount: 2,
                        backgroundCardOffset: const Offset(0, 16),
                        backgroundCardScale: 0.94,
                        threshold: 80,
                        duration: const Duration(milliseconds: 320),
                        onSwipeEnd: _onSwipeEnd,
                        onEnd: () {
                          if (mounted) {
                            setState(() => _stack = const []);
                          }
                        },
                        cardBuilder: (context, i) {
                          final vendor = _stack[i];
                          return VendorCard(
                            vendor: vendor,
                            onTap: () => VendorDetailSheet.show(
                              context,
                              vendor,
                              onAddedFromSwipe: () => _controller.swipeRight(),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            if (_stack.isNotEmpty) _ActionBar(controller: _controller),
            AppSpacing.gapLg,
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(PhosphorIconsThin.arrowLeft),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          Text(
            category.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: AppColors.onSurface,
              letterSpacing: 1.6,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.controller});
  final AppinioSwiperController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _CircleAction(
              icon: PhosphorIconsThin.x,
              onTap: () => controller.swipeLeft(),
              foreground: AppColors.onSurface,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            flex: 2,
            child: _CircleAction(
              icon: PhosphorIconsThin.arrowCounterClockwise,
              onTap: () => controller.unswipe(),
              foreground: AppColors.onSurfaceMuted,
              small: true,
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: _CircleAction(
              icon: PhosphorIconsThin.heart,
              onTap: () => controller.swipeRight(),
              foreground: AppColors.background,
              background: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.foreground,
    this.background,
    this.small = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;
  final Color? background;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 48.0 : 56.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: size,
        decoration: BoxDecoration(
          color: background ?? AppColors.surface,
          borderRadius: AppRadii.fullAll,
          border: background == null
              ? Border.all(color: AppColors.border, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.wineShadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: small ? 20 : 24, color: foreground),
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.onChangeCategory});
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppEmptyState(
              italicTitle: "That's the list",
              subtitle:
                  "You've seen all vendors in this category. Change filters or go back home.",
              icon: PhosphorIconsThin.confetti,
            ),
            AppSpacing.gapMd,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AppButton(
                label: 'Change category',
                onPressed: onChangeCategory,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
