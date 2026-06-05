import 'package:flutter/material.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../core/widgets/gradient_photo.dart';

class DesignShowcaseScreen extends StatefulWidget {
  const DesignShowcaseScreen({super.key});

  @override
  State<DesignShowcaseScreen> createState() => _DesignShowcaseScreenState();
}

class _DesignShowcaseScreenState extends State<DesignShowcaseScreen> {
  VendorCategory _selectedCategory = VendorCategory.restaurant;
  bool _isLoadingDemo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsThin.arrowLeft),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'DESIGN SYSTEM',
          style: AppTypography.overline.copyWith(
            color: AppColors.of(context).onSurface,
            letterSpacing: 1.6,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(child: _ShowcaseHeader()),
            ),
            SliverPadding(
              padding: AppSpacing.screenEdge,
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  AppSpacing.gapXl,
                  const _SectionTitle('Color', '01'),
                  AppSpacing.gapLg,
                  const _ColorSwatches(),
                  AppSpacing.gapXl,
                  const _SectionTitle('Typography', '02'),
                  AppSpacing.gapLg,
                  const _TypographyShowcase(),
                  AppSpacing.gapXl,
                  const _SectionTitle('Editorial mix', '03'),
                  AppSpacing.gapLg,
                  EditorialHeading(
                    style: AppTypography.displayMedium,
                    spans: const [
                      EditorialSpan('For '),
                      EditorialSpan('your wedding', italic: true),
                    ],
                  ),
                  AppSpacing.gapMd,
                  Text(
                    'A curated selection of vendors for the perfect day.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.of(context).onSurfaceMuted,
                    ),
                  ),
                  AppSpacing.gapXl,
                  const _SectionTitle('Buttons', '04'),
                  AppSpacing.gapLg,
                  _ButtonsShowcase(
                    isLoading: _isLoadingDemo,
                    onToggleLoading: () => setState(
                      () => _isLoadingDemo = !_isLoadingDemo,
                    ),
                  ),
                  AppSpacing.gapXl,
                  const _SectionTitle('Inputs', '05'),
                  AppSpacing.gapLg,
                  const _InputsShowcase(),
                  AppSpacing.gapXl,
                  const _SectionTitle('Chips', '06'),
                  AppSpacing.gapLg,
                  const _ChipsShowcase(),
                  AppSpacing.gapXl,
                  const _SectionTitle('Category selector', '07'),
                  AppSpacing.gapLg,
                  SizedBox(
                    height: 140,
                    child: _CategorySelectorPreview(
                      selected: _selectedCategory,
                      onSelect: (c) => setState(() => _selectedCategory = c),
                    ),
                  ),
                  AppSpacing.gapXl,
                  const _SectionTitle('Vendor card', '08'),
                  AppSpacing.gapLg,
                  const _VendorCardPreview(),
                  AppSpacing.gapXl,
                  const _SectionTitle('States', '09'),
                  AppSpacing.gapLg,
                  AppCard(
                    padding: AppSpacing.allMd,
                    child: AppEmptyState(
                      italicTitle: 'Nothing saved yet',
                      subtitle: 'Start swiping to build your list.',
                      actionLabel: 'Get started',
                      onAction: () {},
                      icon: PhosphorIconsThin.heart,
                    ),
                  ),
                  AppSpacing.gapMd,
                  AppCard(
                    padding: AppSpacing.allMd,
                    child: AppErrorState(
                      message:
                          'We could not load the vendors. Check your connection.',
                      onRetry: () {},
                    ),
                  ),
                  AppSpacing.gapMd,
                  const AppCard(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: AppLoading(),
                  ),
                  AppSpacing.gapXl,
                  const _SectionTitle('Skeletons', '10'),
                  AppSpacing.gapLg,
                  const _SkeletonShowcase(),
                  AppSpacing.gapXl,
                  const _SectionTitle('Wedding setup field', '11'),
                  AppSpacing.gapLg,
                  const _WeddingFieldPreview(),
                  AppSpacing.gapXxl,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseHeader extends StatelessWidget {
  const _ShowcaseHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wedding tinder · DESIGN SYSTEM', style: AppTypography.overline),
        AppSpacing.gapSm,
        EditorialHeading(
          style: AppTypography.displayLarge,
          spans: const [
            EditorialSpan('Editorial '),
            EditorialSpan('foundations', italic: true),
          ],
        ),
        AppSpacing.gapMd,
        SizedBox(
          width: 24,
          height: 1,
          child: Container(color: AppColors.of(context).accent),
        ),
      ],
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
      children: [
        Text(number, style: AppTypography.overline),
        AppSpacing.gapMd,
        Container(width: 24, height: 1, color: AppColors.of(context).borderStrong),
        AppSpacing.gapMd,
        Text(title.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppColors.of(context).onSurface)),
      ],
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final swatches = <_SwatchData>[
      _SwatchData('Wine', c.wine, dark: true),
      _SwatchData('Peach', c.peach),
      _SwatchData('Brass', c.brass),
      _SwatchData('Background', c.background),
      _SwatchData('Surface', c.surface),
      _SwatchData('Surface variant', c.surfaceVariant),
      _SwatchData('On surface', c.onSurface, dark: true),
      _SwatchData('Muted', c.onSurfaceMuted, dark: true),
      _SwatchData('Success', c.success, dark: true),
      _SwatchData('Error', c.error, dark: true),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: swatches.map((s) => _SwatchTile(data: s)).toList(),
    );
  }
}

class _SwatchData {
  const _SwatchData(this.name, this.color, {this.dark = false});
  final String name;
  final Color color;
  final bool dark;
}

class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.data});
  final _SwatchData data;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = data.dark ? c.background : c.onSurface;
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.name, style: AppTypography.titleSmall.copyWith(color: fg)),
          Text(
            '#${data.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: AppTypography.overline.copyWith(color: fg.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _TypographyShowcase extends StatelessWidget {
  const _TypographyShowcase();

  @override
  Widget build(BuildContext context) {
    final samples = <(String, TextStyle, String)>[
      ('Display L · Cormorant 56', AppTypography.displayLarge, 'Perfect wedding'),
      ('Display M · Cormorant 44', AppTypography.displayMedium, 'Perfect wedding'),
      ('Display S · Cormorant 34', AppTypography.displaySmall, 'Perfect wedding'),
      ('Headline L · Cormorant 28', AppTypography.headlineLarge, 'Restaurants'),
      ('Headline M · Cormorant 22', AppTypography.headlineMedium, 'Casa Doina'),
      ('Title L · Inter 17 600', AppTypography.titleLarge, 'Vendor details'),
      ('Body L · Inter 16', AppTypography.bodyLarge,
          'Elegant venue in the heart of Bucharest, with custom menus.'),
      ('Body M · Inter 14', AppTypography.bodyMedium,
          'Elegant venue in the heart of Bucharest.'),
      ('Label · Inter 13 500', AppTypography.labelMedium, 'Add to favorites'),
      ('Overline · Inter 11 +1.6', AppTypography.overline, 'RESTAURANT · BUCHAREST'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in samples) ...[
          Text(s.$1,
              style: AppTypography.overline.copyWith(color: AppColors.of(context).accent)),
          AppSpacing.gapXs,
          Text(s.$3, style: s.$2),
          AppSpacing.gapLg,
        ],
      ],
    );
  }
}

class _ButtonsShowcase extends StatelessWidget {
  const _ButtonsShowcase({
    required this.isLoading,
    required this.onToggleLoading,
  });

  final bool isLoading;
  final VoidCallback onToggleLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Start swiping',
          onPressed: () {},
          fullWidth: true,
          isLoading: isLoading,
        ),
        AppSpacing.gapMd,
        AppButton(
          label: 'View favorites',
          onPressed: () {},
          variant: AppButtonVariant.secondary,
          fullWidth: true,
        ),
        AppSpacing.gapMd,
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: isLoading ? 'Stop loading' : 'Simulate loading',
            onPressed: onToggleLoading,
            variant: AppButtonVariant.text,
            icon: PhosphorIconsThin.arrowRight,
          ),
        ),
        AppSpacing.gapMd,
        AppButton(
          label: 'Delete account',
          onPressed: () {},
          variant: AppButtonVariant.destructive,
          fullWidth: true,
        ),
        AppSpacing.gapMd,
        const AppButton(
          label: 'Disabled',
          onPressed: null,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _InputsShowcase extends StatelessWidget {
  const _InputsShowcase();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: PhosphorIconsThin.envelopeSimple,
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Password',
          obscureText: true,
          prefixIcon: PhosphorIconsThin.lock,
          helperText: 'Minimum 8 characters.',
        ),
        AppSpacing.gapLg,
        AppTextField(
          label: 'Invite code',
          hintText: 'WED-XXXX',
          prefixIcon: PhosphorIconsThin.envelope,
        ),
      ],
    );
  }
}

class _ChipsShowcase extends StatefulWidget {
  const _ChipsShowcase();

  @override
  State<_ChipsShowcase> createState() => _ChipsShowcaseState();
}

class _ChipsShowcaseState extends State<_ChipsShowcase> {
  final Set<String> _selected = {'Elegant event'};

  @override
  Widget build(BuildContext context) {
    const tags = ['Elegant event', 'Mid-range budget', 'Inner courtyard', 'Outdoor'];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final t in tags)
          AppChip(
            label: t,
            selected: _selected.contains(t),
            onTap: () => setState(() {
              if (_selected.contains(t)) {
                _selected.remove(t);
              } else {
                _selected.add(t);
              }
            }),
          ),
      ],
    );
  }
}

class _CategorySelectorPreview extends StatelessWidget {
  const _CategorySelectorPreview({
    required this.selected,
    required this.onSelect,
  });

  final VendorCategory selected;
  final ValueChanged<VendorCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: VendorCategory.values.length,
      separatorBuilder: (_, _) => AppSpacing.gapMd,
      itemBuilder: (context, i) {
        final cat = VendorCategory.values[i];
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 120,
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.of(context).primary : AppColors.of(context).surfaceVariant,
              borderRadius: AppRadii.lgAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  cat.icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.of(context).background
                      : AppColors.of(context).onSurface,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.pluralLabel,
                      style: AppTypography.headlineSmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isSelected
                            ? AppColors.of(context).background
                            : AppColors.of(context).onSurface,
                      ),
                    ),
                    Text(
                      '— SELECT',
                      style: AppTypography.overline.copyWith(
                        color: isSelected
                            ? AppColors.of(context).background.withValues(alpha: 0.7)
                            : AppColors.of(context).onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VendorCardPreview extends StatelessWidget {
  const _VendorCardPreview();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).wineShadow,
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder photo — Phase 1+ swaps in real assets.
            const GradientPhoto(
              assetPath: 'assets/images/vendors/_placeholder.jpg',
              gradientHeight: 0.6,
            ),
            // Fallback decorative panel so the showcase looks intentional
            // even without an asset on disk yet.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.of(context).wine.withValues(alpha: 0.85),
                        AppColors.of(context).peach.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.of(context).overlayDark],
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'RESTAURANT · BUCHAREST',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.of(context).background.withValues(alpha: 0.85),
                    ),
                  ),
                  AppSpacing.gapSm,
                  EditorialHeading(
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.of(context).background,
                    ),
                    spans: const [
                      EditorialSpan('Casa ', italic: true),
                      EditorialSpan('Doina'),
                    ],
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      _OverlayBadge(
                        child: Text(
                          '320 - 480 RON / person',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.of(context).background,
                          ),
                        ),
                      ),
                      AppSpacing.gapSm,
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.of(context).brass,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.of(context).background,
                            ),
                          ),
                        ],
                      ),
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
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.child});
  final Widget child;

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
      child: child,
    );
  }
}

class _SkeletonShowcase extends StatelessWidget {
  const _SkeletonShowcase();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 160, height: 22),
          AppSpacing.gapMd,
          SkeletonBox(height: 14),
          AppSpacing.gapSm,
          SkeletonBox(height: 14, width: 220),
          AppSpacing.gapLg,
          Row(
            children: [
              SkeletonBox(width: 60, height: 28, borderRadius: AppRadii.mdAll),
              AppSpacing.gapSm,
              SkeletonBox(width: 80, height: 28, borderRadius: AppRadii.mdAll),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeddingFieldPreview extends StatelessWidget {
  const _WeddingFieldPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorialHeading(
          style: AppTypography.displaySmall,
          spans: const [
            EditorialSpan('Tell us about '),
            EditorialSpan('your wedding', italic: true),
          ],
        ),
        AppSpacing.gapSm,
        Text(
          "We'll personalize recommendations based on these details.",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.of(context).onSurfaceMuted,
          ),
        ),
        AppSpacing.gapXl,
        const AppTextField(
          label: 'Guest count',
          hintText: '150',
          keyboardType: TextInputType.number,
        ),
        AppSpacing.gapLg,
        const AppTextField(
          label: 'Total budget (RON)',
          hintText: '80.000',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
