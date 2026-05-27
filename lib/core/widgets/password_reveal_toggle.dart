import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

class PasswordRevealToggle extends StatelessWidget {
  const PasswordRevealToggle({
    super.key,
    required this.revealed,
    required this.onTap,
  });

  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: revealed ? 'Ascunde parola' : 'Afișează parola',
      splashRadius: 1,
      icon: Icon(
        revealed ? PhosphorIconsThin.eyeSlash : PhosphorIconsThin.eye,
        size: 22,
        color: revealed ? AppColors.primary : AppColors.onSurfaceMuted,
      ),
    );
  }
}
