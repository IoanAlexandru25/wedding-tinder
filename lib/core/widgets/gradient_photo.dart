import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientPhoto extends StatelessWidget {
  const GradientPhoto({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.gradientHeight = 0.55,
  });

  final String assetPath;
  final BoxFit fit;
  final double gradientHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: fit,
          errorBuilder: (context, error, stack) => Container(
            color: AppColors.surfaceVariant,
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              size: 32,
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: gradientHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.overlayDark],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
