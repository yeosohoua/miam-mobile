// PATCH-21
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Petit message flottant aux couleurs du theme.
void showAppToast(BuildContext context, String message) {
  final c = MiamColors.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: interStyle(c.background, size: 14, w: FontWeight.w500, h: 1.2)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.title,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1600),
      ),
    );
}
