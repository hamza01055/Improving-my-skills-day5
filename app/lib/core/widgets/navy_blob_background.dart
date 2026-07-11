import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// White background with two solid navy circle blobs in opposite corners.
class NavyBlobBackground extends StatelessWidget {
  const NavyBlobBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -60, right: -60, child: _blob(180)),
        Positioned(bottom: -70, left: -70, child: _blob(200)),
        child,
      ],
    );
  }

  Widget _blob(double size) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.navy,
        ),
      );
}
