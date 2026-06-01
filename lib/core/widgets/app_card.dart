import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.allLg,
    this.onTap,
    this.borderRadius = AppRadii.cardAll,
    this.background,
    this.elevated = true,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color? background;
  final bool elevated;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: background ?? AppColors.of(context).surface,
        borderRadius: borderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.of(context).wineShadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: container,
      ),
    );
  }
}
