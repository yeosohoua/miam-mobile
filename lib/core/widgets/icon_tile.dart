// PATCH-15
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Tuile d'icone 42 dp (fond + contour), utilisee dans les listes.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, this.color, this.iconSize = 24});
  final IconData icon;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: p.tile,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.line, width: 0.8),
      ),
      child: Icon(icon, size: iconSize, color: color ?? p.c.title),
    );
  }
}
