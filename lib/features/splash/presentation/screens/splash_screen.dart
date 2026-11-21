// PATCH-27
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/branding/miam_logo.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../login/presentation/screens/welcome_screen.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';

const _ink = Color(0xFF1C1C1C);

/// Ecran de demarrage: fond blanc, logo Miam qui apparait en douceur,
/// puis fondu vers l'ecran d'accueil.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 1900), _next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, __, ___) => AuthService.instance.isSignedIn ? const NavigatorScreen() : const WelcomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CurvedAnimation(parent: _c, curve: const Interval(0, 0.7, curve: Curves.easeOutBack));
    final fade = CurvedAnimation(parent: _c, curve: const Interval(0, 0.5, curve: Curves.easeOut));
    final text = CurvedAnimation(parent: _c, curve: const Interval(0.35, 1, curve: Curves.easeOutCubic));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(logo),
                  child: Image.memory(
                    kMiamLogoBytes,
                    width: 96,
                    height: 96,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeTransition(
                opacity: text,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(text),
                  child: const Text(
                    'Miam',
                    style: TextStyle(
                      fontFamily: 'packages/miam_assets/DM Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 34,
                      color: _ink,
                      letterSpacing: -0.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
