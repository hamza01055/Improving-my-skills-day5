import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Subtle brand-colored glow behind screen content.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -80,
          child: _blob(AppColors.primary.withValues(alpha: 0.25)),
        ),
        Positioned(
          bottom: -140,
          right: -100,
          child: _blob(AppColors.secondary.withValues(alpha: 0.20)),
        ),
        child,
      ],
    );
  }

  Widget _blob(Color color) => Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
}
