// PATCH-12
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'blur_sheet.dart';

const _inter = 'packages/miam_assets/Inter';

/// Bottom sheet "Where to get a join code".
/// Retourne true si l'utilisateur choisit "Type its web address instead".
Future<bool?> showJoinCodeHelpSheet(BuildContext context) =>
    showBlurSheet<bool>(context, child: const _HelpContent());

TextStyle _style(Color c) => TextStyle(
      fontFamily: _inter,
      fontWeight: FontWeight.w500,
      fontSize: 13.4,
      height: 1.2,
      letterSpacing: -0.2,
      color: c,
      decoration: TextDecoration.none,
    );

class _HelpContent extends StatelessWidget {
  const _HelpContent();

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tile = dark ? const Color(0xFF191919) : const Color(0xFFF6F6F6);
    final line = dark ? const Color(0xFF6E6E6E) : const Color(0xFFDEDEDE);
    final soft = dark ? Colors.white : const Color(0xFF8A8A8A);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 29),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            child: Row(
              children: [
                const SizedBox(width: 36),
                Expanded(
                  child: Text('Where to get a join code', textAlign: TextAlign.center, style: _style(c.title)),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.cancel_outlined, size: 20, color: soft),
                  ),
                ),
              ],
            ),
          ),
          _Row(
            icon: Icons.qr_code_2,
            text: "Look for a QR code or join code on the marketplace's website or posters",
            tile: tile, line: line, fg: c.title, soft: soft,
          ),
          const SizedBox(height: 14),
          _Row(
            icon: Icons.group_outlined,
            text: 'Ask the business that invited you',
            tile: tile, line: line, fg: c.title, soft: soft,
          ),
          const SizedBox(height: 14),
          _Row(
            icon: Icons.public,
            text: 'Type its web address instead',
            tile: tile, line: line, fg: c.title, soft: soft,
            chevron: true,
            onTap: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.text,
    required this.tile,
    required this.line,
    required this.fg,
    required this.soft,
    this.chevron = false,
    this.onTap,
  });
  final IconData icon;
  final String text;
  final Color tile, line, fg, soft;
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tile,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: line, width: 1.2),
            ),
            child: Icon(icon, size: 22, color: soft),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: _style(fg))),
          if (chevron) Icon(Icons.chevron_right, size: 22, color: fg),
        ],
      ),
    );
  }
}
