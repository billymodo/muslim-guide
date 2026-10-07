import 'package:flutter/material.dart';

/// Centralized color tokens for the application.
class AppColors {
  new _();

  /// Primary brand color and Material 3 seed.
  static const Color primary = Color(0xFF2E7D32);

  /// Dark variant of the primary brand color.
  static const Color primaryDark = Color(0xFF1B5E20);

  /// Accent color.
  static const Color accent = Color(0xFFF9A825);

  /// Light theme background color.
  static const Color background = Color(0xFFFAFAFA);

  /// Default surface color.
  static const Color surface = Colors.white;

  /// Error color.
  static const Color error = Color(0xFFD32F2F);

  /// Scrim color used over hero imagery.
  static const Color heroScrimVertical = Color(0xCC000000);

  /// Creates the light Material 3 color scheme.
  static ColorScheme lightScheme() => ColorScheme.fromSeed(
    seedColor: primary,
  );

  /// Creates the dark Material 3 color scheme.
  static ColorScheme darkScheme() => ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
  );
}
