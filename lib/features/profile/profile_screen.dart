import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/editorial_heading.dart';
import '../../core/constants/app_theme_variant.dart';
import '../../providers/session_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final wedding = session.wedding;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.xl,
            bottom: AppSpacing.huge,
          ),
          children: [
            Padding(
              padding: AppSpacing.screenEdge,
              child: Text('OUR PROFILE', style: AppTypography.overline),
            ),
            AppSpacing.gapMd,
            Padding(
              padding: AppSpacing.screenEdge,
              child: EditorialHeading(
                style: AppTypography.displayLarge,
                spans: [
                  const EditorialSpan('Hello, '),
                  EditorialSpan(user?.displayName ?? '—', italic: true),
                  const EditorialSpan('.'),
                ],
              ),
            ),
            AppSpacing.gapSm,
            if (user != null)
              Padding(
                padding: AppSpacing.screenEdge,
                child: Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.of(context).onSurfaceMuted,
                  ),
                ),
              ),
            AppSpacing.gapXl,
            if (wedding != null) ...[
              Padding(
                padding: AppSpacing.screenEdge,
                child: _WeddingCard(
                  dateRange:
                      '${Formatters.longDate(wedding.weddingDateStart)} – ${Formatters.longDate(wedding.weddingDateEnd)}',
                  guests: wedding.guestCount,
                  budget:
                      '${Formatters.ron(wedding.budgetMin)} – ${Formatters.ron(wedding.budgetMax)}',
                ),
              ),
              AppSpacing.gapLg,
              Padding(
                padding: AppSpacing.screenEdge,
                child: _InviteCodeCard(code: wedding.inviteCode),
              ),
            ],
            AppSpacing.gapXl,
            Padding(
              padding: AppSpacing.screenEdge,
              child: _AppearanceSection(),
            ),
            AppSpacing.gapXl,
            Padding(
              padding: AppSpacing.screenEdge,
              child: _ListAction(
                icon: PhosphorIconsThin.pencil,
                label: 'Edit wedding details',
                onTap: () => context.push('/profile/edit-wedding'),
              ),
            ),
            Padding(
              padding: AppSpacing.screenEdge,
              child: _ListAction(
                icon: PhosphorIconsThin.palette,
                label: 'Design system',
                onTap: () => context.push('/_dev/design'),
              ),
            ),
            AppSpacing.gapXl,
            Padding(
              padding: AppSpacing.screenEdge,
              child: AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  ref.read(sessionProvider.notifier).signOut();
                },
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('APPEARANCE', style: AppTypography.overline),
        AppSpacing.gapMd,
        Row(
          children: [
            for (final variant in AppThemeVariant.values) ...[
              if (variant != AppThemeVariant.values.first) AppSpacing.gapSm,
              Expanded(
                child: _ThemeOption(
                  variant: variant,
                  isSelected: current == variant,
                  onTap: () =>
                      ref.read(themeProvider.notifier).setVariant(variant),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeVariant variant;
  final bool isSelected;
  final VoidCallback onTap;

  static Color _swatchFor(AppThemeVariant v) => switch (v) {
        AppThemeVariant.rose => AppColors.rose.wine,
        AppThemeVariant.midnight => AppColors.midnight.wine,
        AppThemeVariant.sage => AppColors.sage.wine,
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final swatch = _swatchFor(variant);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? c.surfaceVariant : Colors.transparent,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: isSelected ? c.borderStrong : c.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            AppSpacing.gapXs,
            Text(
              variant.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? c.onSurface : c.onSurfaceMuted,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeddingCard extends StatelessWidget {
  const _WeddingCard({
    required this.dateRange,
    required this.guests,
    required this.budget,
  });

  final String dateRange;
  final int guests;
  final String budget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wedding details', style: AppTypography.overline),
          AppSpacing.gapMd,
          _Row(label: 'Date', value: dateRange),
          _Row(label: 'Guests', value: '$guests'),
          _Row(label: 'Budget', value: budget),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
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
            width: 80,
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.of(context).onSurfaceMuted,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.of(context).onSurface,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVITE PARTNER CODE',
            style: AppTypography.overline.copyWith(
              color: AppColors.of(context).background.withValues(alpha: 0.65),
              letterSpacing: 1.6,
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.of(context).background,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied.')),
                    );
                  }
                },
                child: Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.of(context).background.withValues(alpha: 0.35),
                    ),
                    borderRadius: AppRadii.smAll,
                  ),
                  child: Icon(
                    PhosphorIconsThin.copy,
                    size: 18,
                    color: AppColors.of(context).background,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListAction extends StatelessWidget {
  const _ListAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.of(context).border),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.of(context).onSurface),
            AppSpacing.gapMd,
            Expanded(
              child: Text(label, style: AppTypography.bodyLarge),
            ),
            Icon(
              PhosphorIconsThin.caretRight,
              size: 18,
              color: AppColors.of(context).onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}
