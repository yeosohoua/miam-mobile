// PATCH-13
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';

const _inter = 'packages/miam_assets/Inter';
const _dmSans = 'packages/miam_assets/DM Sans';

/// Ecran "Signed in successfully!".
class SignedInScreen extends StatefulWidget {
  const SignedInScreen({super.key});

  @override
  State<SignedInScreen> createState() => _SignedInScreenState();
}

class _SignedInScreenState extends State<SignedInScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..forward();
  bool _loading = false;

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    setState(() => _loading = true);
    // TODO: charger le profil / la session avant d'entrer dans l'app.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const NavigatorScreen()), (_) => false);
  }

  Animation<double> _iv(double b, double e, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _a, curve: Interval(b, e, curve: curve));

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final inset = MediaQuery.paddingOf(context).bottom;
    final outer = dark ? const Color(0xFF051F0F) : const Color(0xFFEEFAF2);
    final inner = dark ? const Color(0xFF11622F) : const Color(0xFF9DE5B7);
    const green = Color(0xFF22C55E);
    final ring = _iv(0.0, 0.55, Curves.easeOutBack);
    final dot = _iv(0.15, 0.7, Curves.easeOutBack);
    final texts = _iv(0.4, 0.95);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, inset + 8),
          child: Column(
            children: [
              const Spacer(flex: 56),
              ScaleTransition(
                scale: Tween<double>(begin: 0.4, end: 1).animate(ring),
                child: FadeTransition(
                  opacity: _iv(0, 0.3),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: outer, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.3, end: 1).animate(dot),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: inner, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(AppIcons.check, size: 20, color: green),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 29),
              FadeTransition(
                opacity: texts,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(texts),
                  child: Column(
                    children: [
                      Text(
                        'Signed in successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _dmSans,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.7,
                          height: 1.25,
                          letterSpacing: -0.6,
                          color: c.title,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You can now start using the app',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _inter,
                          fontSize: 14,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: c.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 44),
              FadeTransition(
                opacity: _iv(0.5, 1),
                child: LoadingButton(label: 'Continue', loading: _loading, onTap: _continue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
