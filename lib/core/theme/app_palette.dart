// PATCH-16
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Couleurs secondaires partagees (tuiles, traits, puces), clair / sombre.
class AppPalette {
  AppPalette(BuildContext context)
      : dark = Theme.of(context).brightness == Brightness.dark,
        c = MiamColors.of(context);
  final bool dark;
  final MiamColors c;

  Color get tile => dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6);
  Color get line => dark ? const Color(0xFF6E6E6E) : const Color(0xFFDEDEDE);
  Color get divider => dark ? const Color(0xFF6E6E6E) : const Color(0xFFDEDEDE);
  Color get chipNeutral => dark ? const Color(0xFF262626) : const Color(0xFFEDEDED);
  Color get coral => dark ? const Color(0xFFE46D62) : const Color(0xFFD03025);
  Color get mutedText => dark ? const Color(0xFFCECECE) : const Color(0xFF8A8A8A);
  // Statuts de commande.
  Color get pendingText => dark ? const Color(0xFFFFCD66) : const Color(0xFF996700);
  Color get pendingBg => dark ? const Color(0xFF281B00) : const Color(0xFFFFF7E5);
  Color get infoText => dark ? const Color(0xFFA4D6F3) : const Color(0xFF176A9F);
  Color get infoBg => dark ? const Color(0xFF041823) : const Color(0xFFE8F5FD);
  Color get countBg => dark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
  Color get appBarScrolled => dark ? const Color(0xFF4F4F4F) : const Color(0xFFDCDCDC);
}

TextStyle interStyle(Color color, {double size = 14.1, FontWeight w = FontWeight.w400, double h = 1.3, double ls = -0.2}) =>
    TextStyle(
      fontFamily: 'packages/miam_assets/Inter',
      fontWeight: w,
      fontSize: size,
      height: h,
      letterSpacing: ls,
      color: color,
      decoration: TextDecoration.none,
    );

TextStyle dmStyle(Color color, {double size = 15.5, FontWeight w = FontWeight.w500, double h = 1.25, double ls = -0.45}) =>
    TextStyle(
      fontFamily: 'packages/miam_assets/DM Sans',
      fontWeight: w,
      fontSize: size,
      height: h,
      letterSpacing: ls,
      color: color,
      decoration: TextDecoration.none,
    );

/// Distance haut de boite -> ligne de base pour un texte a height = 1.
/// (Flutter repartit l'interligne proportionnellement a l'ascent / descent.)
class DmBase {
  const DmBase._(this.ascentBox);
  final double ascentBox;

  // DM Sans: ascent 0.992, descent 0.310.
  factory DmBase.dm(double size) => DmBase._(size * 0.992 / 1.302);
  // Inter: ascent 0.9688, descent 0.2415.
  factory DmBase.inter(double size) => DmBase._(size * 0.9688 / 1.2103);
}
