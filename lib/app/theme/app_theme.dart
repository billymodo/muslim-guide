import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/app/theme/app_typography.dart';

/// Material 3 themes for light and dark display modes.
class AppTheme {
  new _();

  /// Creates the light theme.
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightScheme(),
    textTheme: AppTypography.textTheme,
  );

  /// Creates the dark theme.
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkScheme(),
    textTheme: AppTypography.textTheme,
  );
}
