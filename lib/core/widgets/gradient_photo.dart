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

  static bool _isNetworkUrl(String path) => path.startsWith('http');

  Widget _buildImage(BuildContext context) {
    final c = AppColors.of(context);
    final placeholder = Container(
      color: c.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: c.onSurfaceMuted,
      ),
    );
    if (_isNetworkUrl(assetPath)) {
      return Image.network(
        assetPath,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, error, stack) => placeholder,
      );
    }
    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: gradientHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.of(context).overlayDark],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
