import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
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
            color: c.navBarBackground,
            borderRadius: AppRadii.lgAll,
            boxShadow: [
              BoxShadow(
                color: c.wineShadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GNav(
            gap: AppSpacing.sm,
            activeColor: c.navBarActiveContent,
            color: c.navBarContent.withValues(alpha: 0.55),
            iconSize: 20,
            tabBackgroundColor: c.navBarTabPill,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            tabBorderRadius: AppRadii.md,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            haptic: true,
            textStyle: AppTypography.overline.copyWith(
              color: c.navBarActiveContent,
              letterSpacing: 1.4,
            ),
            tabs: const [
              GButton(
                icon: PhosphorIconsThin.houseLine,
                text: 'HOME',
              ),
              GButton(
                icon: PhosphorIconsThin.heart,
                text: 'FAVORITES',
              ),
              GButton(
                icon: PhosphorIconsThin.userCircle,
                text: 'PROFILE',
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
