// PATCH-12
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Intensite du flou d'arriere-plan (dp), relevee sur les captures de reference.
const double kSheetBlurSigma = 9;

/// Ouvre un bottom sheet avec flou d'arriere-plan (sans voile de couleur),
/// identique en clair et en sombre. Le [child] ferme le sheet avec
/// `Navigator.of(context).pop(valeur)`.
Future<T?> showBlurSheet<T>(BuildContext context, {required Widget child, bool dismissible = true}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: 'Close',
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (_, __, ___) => _BlurSheetHost(dismissible: dismissible, child: child),
  );
}

class _BlurSheetHost extends StatefulWidget {
  const _BlurSheetHost({required this.child, required this.dismissible});
  final Widget child;
  final bool dismissible;

  @override
  State<_BlurSheetHost> createState() => _BlurSheetHostState();
}

class _BlurSheetHostState extends State<_BlurSheetHost> {
  double _drag = 0;

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final route = ModalRoute.of(context)!;
    final anim = CurvedAnimation(
      parent: route.animation!,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final line = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6E6E6E)
        : const Color(0xFFDEDEDE);

    return Stack(
      children: [
        // Flou plein ecran: le sigma suit l'animation, aucun voile de couleur.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.dismissible ? _close : null,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, __) {
                final s = kSheetBlurSigma * anim.value;
                return ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: s, sigmaY: s),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: anim,
            child: RepaintBoundary(
              child: GestureDetector(
                onVerticalDragUpdate: widget.dismissible
                    ? (d) => setState(() => _drag = (_drag + d.delta.dy).clamp(0.0, 700.0))
                    : null,
                onVerticalDragEnd: widget.dismissible
                    ? (d) {
                        if (_drag > 110 || (d.primaryVelocity ?? 0) > 700) {
                          _close();
                        } else {
                          setState(() => _drag = 0);
                        }
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    border: Border(top: BorderSide(color: line, width: 1.3)),
                  ),
                  child: widget.child,
                ),
              ),
            ),
            builder: (_, child) => FractionalTranslation(
              translation: Offset(0, 1 - anim.value),
              child: Transform.translate(offset: Offset(0, _drag), child: child),
            ),
          ),
        ),
      ],
    );
  }
}
