import 'package:flutter/material.dart';

/// Brand palette: deep violet + electric blue, per the design brief.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C4DF6); // violet
  static const Color secondary = Color(0xFF2E8BFF); // blue
  static const Color navy = Color(0xFF1A2A80); // auth screens accent

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // Surfaces
  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color darkBackground = Color(0xFF0E0F16);
  static const Color darkSurface = Color(0xFF181A24);

  // Feedback
  static const Color success = Color(0xFF2FBF71);
  static const Color error = Color(0xFFE5484D);
}
