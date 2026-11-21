// PATCH-24
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import 'profile_screen.dart';

/// Onglet Profile: Navigator imbrique, la barre du bas reste visible.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.navKey, required this.depth});
  final GlobalKey<NavigatorState> navKey;
  final ValueNotifier<int> depth;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      observers: [_DepthObserver(depth)],
      onGenerateRoute: (s) {
        final name = s.name ?? '/';
        final b = name == '/' ? (_) => const ProfileScreen() : AppRouter.routes[name];
        if (b == null) return null;
        return PageRouteBuilder<void>(
          settings: s,
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (c, a, _) => b(c),
          transitionsBuilder: (c, a, _, child) {
            if (name == '/') return child;
            final t = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: t,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(t),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}

class _DepthObserver extends NavigatorObserver {
  _DepthObserver(this.depth);
  final ValueNotifier<int> depth;
  void _sync() => WidgetsBinding.instance.addPostFrameCallback((_) => depth.value = (navigator?.canPop() ?? false) ? 1 : 0);
  @override
  void didPush(Route<dynamic> r, Route<dynamic>? p) => _sync();
  @override
  void didPop(Route<dynamic> r, Route<dynamic>? p) => _sync();
  @override
  void didRemove(Route<dynamic> r, Route<dynamic>? p) => _sync();
}
