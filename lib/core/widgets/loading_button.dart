// PATCH-21
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bouton (44 dp) avec animation de chargement: un spinner apparait a gauche
/// du texte (a la place de l'icone), comme le bouton Continue de l'onboarding.
///
/// - `onTap == null` (et pas en chargement): aspect desactive (gris).
/// - `outlined`: variante a contour, fond translucide.
/// - `locked`: un autre bouton est en cours -> attenue (0.4) et inactif.
class LoadingButton extends StatefulWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.outlined = false,
    this.locked = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool outlined;
  final bool locked;
  final Widget? icon;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final disabled = widget.onTap == null && !widget.loading && !widget.locked;
    final enabled = widget.onTap != null && !widget.loading && !widget.locked;

    final Color bg = widget.outlined
        ? c.background.withValues(alpha: 0.62)
        : (disabled ? c.disabled : c.primary);
    final Color fg = widget.outlined ? c.title : (disabled ? c.onDisabled : c.onPrimary);

    final Widget? lead = widget.loading
        ? Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CupertinoActivityIndicator(radius: 8, color: fg.withValues(alpha: 0.8)),
          )
        : (widget.icon != null ? Padding(padding: const EdgeInsets.only(right: 10), child: widget.icon) : null);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: widget.locked ? 0.4 : (_down ? 0.85 : 1),
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: widget.outlined ? Border.all(color: c.outline) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: lead ?? const SizedBox.shrink(),
                ),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'packages/miam_assets/Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.1,
                    height: 1.2,
                    letterSpacing: -0.4,
                    color: fg,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
