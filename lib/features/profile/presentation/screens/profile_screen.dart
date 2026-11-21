// PATCH-27
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../login/presentation/screens/welcome_screen.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/grace_avatar.dart';
import '../../../../core/widgets/icon_tile.dart';

// Mesures relevees sur la reference (S918U, 2.8125 px/dp), en dp depuis le
// bas de la barre d'etat. Les textes sont poses par leur ligne de base.
const double _kHeaderH = 70.5; // hauteur de l'en-tete sous la barre d'etat
const double _kTitleBase = 37.45;
const double _kAvatarTop = 58.45;
const double _kAvatarSize = 72;
const double _kNameBase = 164.35;
const double _kPhoneBase = 193.15;
const double _kStatsTop = 218.4;
const double _kStatsH = 81.6;
const double _kRowsTop = 324.4; // haut de la 1re rangee (= haut de tuile - 17 dp)
const double _kRowH = 76;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final s = _scroll.hasClients && _scroll.offset > 0.5;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _go(String route) => Navigator.of(context).pushNamed(route);

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final navH = 78.8 + mq.padding.bottom;

    final items = <_Item>[
      _Item(AppIcons.user, 'Profile info', () => _go('/personal-info')),
      _Item(AppIcons.clockFilled, 'Order history', () => _go('/order-history')),
      _Item(AppIcons.chat, 'Reviews', () => _go('/reviews')),
      _Item(AppIcons.gear, 'Settings', () => _go('/settings')),
      _Item(AppIcons.headset, 'Support Requests', () => _go('/support-requests')),
      _Item(AppIcons.logout, 'Logout', () async {
        await AuthService.instance.signOut();
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(fadeRoute<void>(const WelcomeScreen()), (_) => false);
      }, danger: true),
    ];

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
            // Contenu defilant sous l'en-tete.
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  height: inset + _kRowsTop + items.length * _kRowH + 4.6 + navH,
                  child: Stack(
                    children: [
                      Positioned(
                        top: inset + _kAvatarTop,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ClipOval(
                            child: SizedBox(
                              width: _kAvatarSize,
                              height: _kAvatarSize,
                              child: Image.memory(kGraceAvatarBytes, fit: BoxFit.cover, gaplessPlayback: true),
                            ),
                          ),
                        ),
                      ),
                      _base(inset + _kNameBase, Text('Grace Mitchell', style: dmStyle(c.title, size: 17.4, h: 1, ls: -0.52)), DmBase.dm(17.4)),
                      _base(inset + _kPhoneBase, Text('(201) 555-0125', style: interStyle(p.mutedText, size: 14, h: 1, ls: -0.28)), DmBase.inter(14)),
                      Positioned(
                        top: inset + _kStatsTop,
                        left: 16,
                        right: 16,
                        height: _kStatsH,
                        child: _StatsBox(p: p),
                      ),
                      for (var i = 0; i < items.length; i++)
                        Positioned(
                          top: inset + _kRowsTop + i * _kRowH,
                          left: 16,
                          right: 16,
                          height: _kRowH,
                          child: _Row(item: items[i], p: p, last: i == items.length - 1),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // En-tete (titre + fond gris quand le contenu passe dessous).
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: inset + _kHeaderH,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  color: _scrolled ? p.appBarScrolled : Colors.transparent,
                  child: Stack(
                    children: [
                      _base(inset + _kTitleBase, Text('Profile', textAlign: TextAlign.center, style: dmStyle(c.title, size: 15.6, h: 1, ls: -0.47)), DmBase.dm(15.6), full: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pose [child] pour que sa ligne de base soit a [baseline] dp du haut.
  Widget _base(double baseline, Widget child, DmBase m, {bool full = false}) {
    return Positioned(
      top: baseline - m.ascentBox,
      left: 0,
      right: 0,
      child: Center(child: child),
    );
  }
}

class _Item {
  const _Item(this.icon, this.label, this.onTap, {this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
}

class _StatsBox extends StatelessWidget {
  const _StatsBox({required this.p});
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.line, width: 0.8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 18.4,
            height: 43.4,
            child: Center(child: SizedBox(width: 0.8, child: ColoredBox(color: p.line))),
          ),
          Row(
            children: [
              Expanded(child: _Stat(p: p, label: 'Total Orders', icon: AppIcons.basketFilled, value: '1')),
              Expanded(child: _Stat(p: p, label: 'Reviews', icon: AppIcons.chat, value: '0')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.p, required this.label, required this.icon, required this.value});
  final AppPalette p;
  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = p.c;
    // Haut de la boite = bord interieur (bordure 0.8 dp); mesures depuis le bord externe.
    // Ligne de base a 28.8 dp du bord externe (28.0 dans la bordure); Inter 12, h 1.
    const label0 = 28.0 - 12 * 0.9688 / 1.2103;
    return Stack(
      children: [
        Positioned(
          top: label0,
          left: 0,
          right: 0,
          child: Center(child: Text(label, style: interStyle(p.mutedText, size: 12, h: 1, ls: -0.24))),
        ),
        Positioned(
          top: 39.6,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 24, height: 24, child: Icon(icon, size: 24, color: c.title)),
              const SizedBox(width: 11.4),
              Text(value, style: dmStyle(c.title, size: 17.4, h: 1.4, ls: -0.52)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.item, required this.p, required this.last});
  final _Item item;
  final AppPalette p;
  final bool last;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final it = widget.item;
    final color = it.danger ? p.coral : p.c.title;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: it.onTap,
      child: AnimatedOpacity(
        opacity: _down ? 0.6 : 1,
        duration: const Duration(milliseconds: 90),
        child: Column(
          children: [
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.only(left: 5.3),
              child: Row(
                children: [
                  IconTile(icon: it.icon, color: color, iconSize: 20),
                  const SizedBox(width: 8.5),
                  Expanded(child: Text(it.label, style: interStyle(p.c.title, size: 14.2, h: 1.2, ls: -0.28))),
                ],
              ),
            ),
            const Spacer(),
            if (!widget.last) Container(height: 0.8, color: p.divider),
          ],
        ),
      ),
    );
  }
}
