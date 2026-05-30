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
import '../../providers/session_provider.dart';

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
              child: Text('CONT', style: AppTypography.overline),
            ),
            AppSpacing.gapMd,
            Padding(
              padding: AppSpacing.screenEdge,
              child: EditorialHeading(
                style: AppTypography.displayLarge,
                spans: [
                  const EditorialSpan('Bună, '),
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
                    color: AppColors.onSurfaceMuted,
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
              child: _ListAction(
                icon: PhosphorIconsThin.pencil,
                label: 'Editare detalii nuntă',
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
                label: 'Deconectare',
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
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETALII NUNTĂ', style: AppTypography.overline),
          AppSpacing.gapMd,
          _Row(label: 'Data', value: dateRange),
          _Row(label: 'Invitați', value: '$guests'),
          _Row(label: 'Buget', value: budget),
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
                color: AppColors.onSurfaceMuted,
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
        color: AppColors.onSurface,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COD INVITAȚIE PARTENER',
            style: AppTypography.overline.copyWith(
              color: AppColors.background.withValues(alpha: 0.65),
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
                    color: AppColors.background,
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
                      const SnackBar(content: Text('Cod copiat.')),
                    );
                  }
                },
                child: Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.background.withValues(alpha: 0.35),
                    ),
                    borderRadius: AppRadii.smAll,
                  ),
                  child: Icon(
                    PhosphorIconsThin.copy,
                    size: 18,
                    color: AppColors.background,
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
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.onSurface),
            AppSpacing.gapMd,
            Expanded(
              child: Text(label, style: AppTypography.bodyLarge),
            ),
            Icon(
              PhosphorIconsThin.caretRight,
              size: 18,
              color: AppColors.onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}
