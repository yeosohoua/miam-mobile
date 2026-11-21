// PATCH-27
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/branding/miam_logo.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';
import 'onboarding_screen.dart';
import 'phone_login_screen.dart';

/// Ecran d'accueil avant la saisie du code: fond anime doux, carte en verre,
/// trois boutons (code, telephone, Google). Suit le theme du telephone.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);

  late final Animation<double> _aHeader = _curve(0.00, 0.40);
  late final Animation<double> _aCard = _curve(0.10, 0.60);
  late final Animation<double> _aBtn1 = _curve(0.38, 0.78);
  late final Animation<double> _aBtn2 = _curve(0.46, 0.86);
  late final Animation<double> _aBtn3 = _curve(0.54, 0.94);
  late final Animation<double> _aTerms = _curve(0.66, 1.00);

  Animation<double> _curve(double a, double b) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _intro.dispose();
    _drift.dispose();
    super.dispose();
  }

  Widget _rise(Animation<double> a, Widget child, {double dy = 0.3}) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, dy), end: Offset.zero).animate(a),
          child: child,
        ),
      );

  int? _busy; // 1 = code, 2 = telephone, 3 = google

  /// Anime le bouton (spinner), laisse respirer 700 ms puis lance l'action.
  Future<void> _go(int id, FutureOr<void> Function() action) async {
    if (_busy != null) return;
    HapticFeedback.selectionClick();
    setState(() => _busy = id);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await action();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) setState(() => _busy = null);
  }

  void _openCode() => Navigator.of(context).push(fadeRoute<void>(const OnboardingScreen()));
  void _openPhone() => Navigator.of(context).push(fadeRoute<void>(const PhoneLoginScreen()));
  Future<void> _google() async {
    try {
      final u = await AuthService.instance.signInWithGoogle();
      if (u != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(fadeRoute<void>(const NavigatorScreen()), (_) => false);
      }
    } on AuthFailure catch (e) {
      if (mounted) showAppToast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final h = mq.size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Positioned.fill(child: _DriftingBackground(t: _drift, dark: p.dark)),
            Padding(
              padding: EdgeInsets.fromLTRB(0, mq.padding.top + 12, 0, mq.padding.bottom + 12),
              child: Column(
                children: [
                  _rise(
                    _aHeader,
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.memory(
                            kMiamLogoBytes,
                            width: 30,
                            height: 30,
                            color: c.title,
                            colorBlendMode: BlendMode.srcIn,
                            filterQuality: FilterQuality.high,
                          ),
                          const SizedBox(width: 8),
                          Text('Miam', style: dmStyle(c.title, size: 22, h: 1.1, ls: -0.66)),
                        ],
                      ),
                    ),
                    dy: 0.2,
                  ),
                  SizedBox(height: h * 0.065),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, cons) => Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FadeTransition(
                            opacity: _aCard,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.96, end: 1).animate(_aCard),
                              child: _GlassCard(
                                height: math.min(h * 0.37, cons.maxHeight),
                                dark: p.dark,
                                child: Text(
                                  'Your local\nmarketplace,\ndelivered.',
                                  textAlign: TextAlign.center,
                                  style: dmStyle(c.title, size: 30, h: 1.2, ls: -0.9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _rise(
                          _aBtn1,
                          LoadingButton(
                            label: 'Continue with code',
                            loading: _busy == 1,
                            locked: _busy != null && _busy != 1,
                            icon: Icon(Icons.tag_rounded, size: 20, color: c.onPrimary),
                            onTap: () => _go(1, _openCode),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _rise(
                          _aBtn2,
                          LoadingButton(
                            label: 'Continue with phone',
                            outlined: true,
                            loading: _busy == 2,
                            locked: _busy != null && _busy != 2,
                            icon: Icon(Icons.phone_outlined, size: 20, color: c.title),
                            onTap: () => _go(2, _openPhone),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _rise(
                          _aBtn3,
                          LoadingButton(
                            label: 'Continue with google',
                            outlined: true,
                            loading: _busy == 3,
                            locked: _busy != null && _busy != 3,
                            icon: const SizedBox(width: 20, height: 20, child: CustomPaint(painter: _GoogleGPainter())),
                            onTap: () => _go(3, _google),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _aTerms,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text.rich(
                        TextSpan(
                          style: interStyle(c.subtitle, size: 12, h: 1.45, ls: -0.12),
                          children: [
                            const TextSpan(text: 'By continuing you agree to the '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(decoration: TextDecoration.underline, color: c.title)),
                            const TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(decoration: TextDecoration.underline, color: c.title)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fond: halos roses tres doux qui derivent lentement.
class _DriftingBackground extends StatelessWidget {
  const _DriftingBackground({required this.t, required this.dark});
  final Animation<double> t;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pink = AppColors.brandPink;
    final a1 = dark ? 0.40 : 0.30;
    final a2 = dark ? 0.24 : 0.18;
    final neutral = dark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05);

    Widget blob(Alignment al, double size, Color color) => Align(
          alignment: al,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
            ),
          ),
        );

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: t,
          builder: (_, __) {
            final v = Curves.easeInOut.transform(t.value);
            return Stack(
              children: [
                blob(Alignment.lerp(const Alignment(-1.2, -0.75), const Alignment(-0.5, -0.95), v)!, w * 1.25, pink.withValues(alpha: a1)),
                blob(Alignment.lerp(const Alignment(1.3, 0.10), const Alignment(0.7, 0.35), v)!, w * 1.15, pink.withValues(alpha: a2)),
                blob(Alignment.lerp(const Alignment(0.2, 1.1), const Alignment(-0.4, 0.8), v)!, w * 1.0, neutral),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.height, required this.dark, required this.child});
  final double height;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.background.withValues(alpha: dark ? 0.30 : 0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.title.withValues(alpha: 0.16), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// "G" Google simplifie: anneau 4 couleurs + barre bleue.
class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final r = s.width / 2;
    final w = r * 0.36;
    final c = s.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: r - w / 2);
    Paint arc(Color col) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.butt;
    double rad(double d) => d * math.pi / 180;
    canvas.drawArc(rect, rad(-45), rad(90), false, arc(const Color(0xFF4285F4)));
    canvas.drawArc(rect, rad(45), rad(90), false, arc(const Color(0xFF34A853)));
    canvas.drawArc(rect, rad(135), rad(80), false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, rad(215), rad(100), false, arc(const Color(0xFFEA4335)));
    canvas.drawRect(
      Rect.fromLTWH(c.dx, c.dy - w / 2, r - 0.5, w),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
