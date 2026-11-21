import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Polices reelles de l'app: DM Sans et Inter (package miam_assets).
/// Le theme suit automatiquement le mode clair / sombre du telephone.
class AppTheme {
  const AppTheme._();
  static const _seed = Color(0xFF3B5BFE);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        scaffoldBackgroundColor: MiamColors.light.background,
        fontFamily: 'packages/miam_assets/DM Sans',
        extensions: const [MiamColors.light],
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: MiamColors.dark.background,
        fontFamily: 'packages/miam_assets/DM Sans',
        extensions: const [MiamColors.dark],
      );
}
