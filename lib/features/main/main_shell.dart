import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.onSurface,
            borderRadius: AppRadii.lgAll,
            boxShadow: [
              BoxShadow(
                color: AppColors.wineShadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GNav(
            gap: AppSpacing.sm,
            activeColor: AppColors.onSurface,
            color: AppColors.background.withValues(alpha: 0.65),
            iconSize: 20,
            tabBackgroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            tabBorderRadius: AppRadii.md,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            haptic: true,
            textStyle: AppTypography.overline.copyWith(
              color: AppColors.onSurface,
              letterSpacing: 1.4,
            ),
            tabs: const [
              GButton(
                icon: PhosphorIconsThin.houseLine,
                text: 'ACASĂ',
              ),
              GButton(
                icon: PhosphorIconsThin.heart,
                text: 'FAVORITE',
              ),
              GButton(
                icon: PhosphorIconsThin.userCircle,
                text: 'PROFIL',
              ),
            ],
            selectedIndex: navigationShell.currentIndex,
            onTabChange: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
          ),
        ),
      ),
    );
  }
}
