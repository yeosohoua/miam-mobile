// PATCH-24
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';

const double kSubHeaderH = 70.5;

/// Page secondaire: fleche retour + titre centre, contenu defilant dessous.
/// [bottomPad] laisse la place de la barre de navigation.
class SubPage extends StatefulWidget {
  const SubPage({super.key, required this.title, required this.child, this.scrollable = true});
  final String title;
  final Widget child;
  final bool scrollable;

  @override
  State<SubPage> createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final navH = 78.8 + mq.padding.bottom;
    final base = DmBase.dm(15.6).ascentBox;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.depth == 0) {
                    final s = n.metrics.pixels > 0.5;
                    if (s != _scrolled) setState(() => _scrolled = s);
                  }
                  return false;
                },
                child: widget.scrollable
                    ? SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(top: inset + kSubHeaderH, bottom: navH + 24 + mq.viewInsets.bottom),
                        child: widget.child,
                      )
                    : Padding(padding: EdgeInsets.only(top: inset + kSubHeaderH), child: widget.child),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: inset + kSubHeaderH,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                color: _scrolled ? p.appBarScrolled : c.background,
                child: Stack(
                  children: [
                    Positioned(
                      top: inset + 37.75 - base,
                      left: 56,
                      right: 56,
                      child: Text(widget.title,
                          textAlign: TextAlign.center, maxLines: 1, style: dmStyle(c.title, size: 15.6, h: 1, ls: -0.47)),
                    ),
                    Positioned(
                      top: inset + 10,
                      left: 8,
                      width: 56,
                      height: 44,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Center(child: Icon(AppIcons.arrowLeft, size: 24, color: c.title)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne tactile avec attenuation a l'appui.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.onTap, required this.child});
  final VoidCallback? onTap;
  final Widget child;
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedOpacity(opacity: _down ? 0.6 : 1, duration: const Duration(milliseconds: 90), child: widget.child),
      );
}
