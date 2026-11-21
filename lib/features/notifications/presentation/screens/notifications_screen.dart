// PATCH-25
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/sub_page.dart';

/// Notifications: titre centre, bouton fermer, onglets, etat vide.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  /// Ouverture par le bas (ecran modal plein ecran), sans barre de navigation.
  static Route<void> route() => PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => const NotificationsScreen(),
        transitionsBuilder: (_, a, __, child) {
          final t = CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
          return FadeTransition(
            opacity: t,
            child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(t), child: child),
          );
        },
      );

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0;
  static const _tabs = ['All', 'Orders', 'Announcements'];

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final inset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Positioned(
              top: inset + 35.35 - DmBase.dm(14.4).ascentBox,
              left: 56,
              right: 56,
              child: Text('Notifications', textAlign: TextAlign.center, style: dmStyle(c.title, size: 14.4, h: 1, ls: -0.47)),
            ),
            Positioned(
              top: inset + 8.85,
              right: 8,
              width: 44,
              height: 44,
              child: Pressable(
                onTap: () => Navigator.of(context).maybePop(),
                child: Center(child: Icon(AppIcons.closeCircle, size: 22, color: p.mutedText)),
              ),
            ),
            Positioned(
              top: inset + 68.35,
              left: 19.9,
              right: 16,
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8.2),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        height: 41.3,
                        padding: const EdgeInsets.symmetric(horizontal: 10.3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: _tab == i ? c.field : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: interStyle(_tab == i ? c.title : p.mutedText, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.28),
                          child: Text(_tabs[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: inset + 363.15,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: p.dark ? 0.46 : 1,
                  child: Image.asset('packages/miam_assets/images/empty_states/noNotification.png', width: 142, height: 142),
                ),
              ),
            ),
            Positioned(
              top: inset + 551.55 - DmBase.inter(16).ascentBox + 12.4 - 0.3,
              left: 0,
              right: 0,
              child: Text('“ No notifications ”', textAlign: TextAlign.center, style: interStyle(p.mutedText, size: 16, h: 1, ls: -0.3)),
            ),
          ],
        ),
      ),
    );
  }
}
