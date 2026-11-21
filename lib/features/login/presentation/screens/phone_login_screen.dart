// PATCH-27
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../home/presentation/screens/guest_home_screen.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';
import 'otp_screen.dart';
import '../widgets/blur_sheet.dart';

enum _FlagKind { vertical, horizontal, benin }

class _Country {
  const _Country(this.name, this.dial, this.stripes, this.pattern, {this.kind = _FlagKind.vertical, this.dot});
  final String name;
  final String dial;
  final List<Color> stripes;
  final List<int> pattern; // groupes de chiffres du numero national
  final _FlagKind kind;
  final Color? dot; // disque central (Niger)
  int get digits => pattern.fold(0, (a, b) => a + b);
}

// Ordre alphabetique, comme dans la reference. Cote d'Ivoire = pays par defaut.
const _countries = <_Country>[
  _Country('Belgium', '+32', [Color(0xFF000000), Color(0xFFFDDA24), Color(0xFFEF3340)], [3, 2, 2, 2]),
  _Country('Benin', '+229', [Color(0xFF008751), Color(0xFFFCD116), Color(0xFFE8112D)], [2, 2, 2, 2, 2], kind: _FlagKind.benin),
  _Country('Burkina Faso', '+226', [Color(0xFFEF2B2D), Color(0xFF009E49)], [2, 2, 2, 2], kind: _FlagKind.horizontal),
  _Country('Cameroon', '+237', [Color(0xFF007A5E), Color(0xFFCE1126), Color(0xFFFCD116)], [1, 2, 2, 2, 2]),
  _Country('Chad', '+235', [Color(0xFF002664), Color(0xFFFECB00), Color(0xFFC60C30)], [2, 2, 2, 2]),
  _Country("Côte d'Ivoire", '+225', [Color(0xFFF77F00), Color(0xFFFFFFFF), Color(0xFF009E60)], [2, 2, 2, 2, 2]),
  _Country('France', '+33', [Color(0xFF0055A4), Color(0xFFFFFFFF), Color(0xFFEF4135)], [1, 2, 2, 2, 2]),
  _Country('Gabon', '+241', [Color(0xFF009E60), Color(0xFFFCD116), Color(0xFF3A75C4)], [2, 2, 2, 2], kind: _FlagKind.horizontal),
  _Country('Germany', '+49', [Color(0xFF000000), Color(0xFFDD0000), Color(0xFFFFCE00)], [3, 4, 4], kind: _FlagKind.horizontal),
  _Country('Ghana', '+233', [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF006B3F)], [2, 3, 4], kind: _FlagKind.horizontal),
  _Country('Guinea', '+224', [Color(0xFFCE1126), Color(0xFFFCD116), Color(0xFF009460)], [3, 2, 2, 2]),
  _Country('Ireland', '+353', [Color(0xFF169B62), Color(0xFFFFFFFF), Color(0xFFFF883E)], [2, 3, 4]),
  _Country('Italy', '+39', [Color(0xFF009246), Color(0xFFFFFFFF), Color(0xFFCE2B37)], [3, 3, 4]),
  _Country('Mali', '+223', [Color(0xFF14B53A), Color(0xFFFCD116), Color(0xFFCE1126)], [2, 2, 2, 2]),
  _Country('Netherlands', '+31', [Color(0xFFAE1C28), Color(0xFFFFFFFF), Color(0xFF21468B)], [1, 4, 4], kind: _FlagKind.horizontal),
  _Country('Niger', '+227', [Color(0xFFE05206), Color(0xFFFFFFFF), Color(0xFF0DB02B)], [2, 2, 2, 2], kind: _FlagKind.horizontal, dot: Color(0xFFE05206)),
  _Country('Nigeria', '+234', [Color(0xFF008751), Color(0xFFFFFFFF), Color(0xFF008751)], [3, 3, 4]),
  _Country('Poland', '+48', [Color(0xFFFFFFFF), Color(0xFFDC143C)], [3, 3, 3], kind: _FlagKind.horizontal),
  _Country('Senegal', '+221', [Color(0xFF00853F), Color(0xFFFDEF42), Color(0xFFE31B23)], [2, 3, 2, 2]),
];

_Country get _defaultCountry => _countries.firstWhere((k) => k.dial == '+225');

/// Regroupe les chiffres selon le format du pays ("07 12 34 56 78").
class _PhoneFormatter extends TextInputFormatter {
  _PhoneFormatter(this.pattern);
  final List<int> pattern;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    final max = pattern.fold(0, (a, b) => a + b);
    if (d.length > max) d = d.substring(0, max);
    final out = StringBuffer();
    var i = 0;
    for (final g in pattern) {
      if (i >= d.length) break;
      if (out.isNotEmpty) out.write(' ');
      out.write(d.substring(i, i + g > d.length ? d.length : i + g));
      i += g;
    }
    final t = out.toString();
    return TextEditingValue(text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

/// Connexion par telephone: indicatif + numero + "Send Code".
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  _Country _country = _defaultCountry;
  bool _sending = false;

  late final Animation<double> _aTop = _curve(0.00, 0.55);
  late final Animation<double> _aField = _curve(0.20, 0.75);
  late final Animation<double> _aBottom = _curve(0.35, 1.00);

  Animation<double> _curve(double a, double b) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _intro.dispose();
    super.dispose();
  }

  bool get _valid => _ctrl.text.replaceAll(' ', '').length == _country.digits;

  Widget _rise(Animation<double> a, Widget child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(a),
          child: child,
        ),
      );

  Future<void> _pickCountry() async {
    FocusScope.of(context).unfocus();
    final r = await showBlurSheet<_Country>(context, child: _CountrySheet(selected: _country));
    if (r != null && r != _country && mounted) {
      setState(() {
        _country = r;
        _ctrl.clear();
      });
    }
  }

  Future<void> _send() async {
    if (_sending || !_valid) return;
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    final digits = _ctrl.text.replaceAll(' ', '');
    final e164 = '${_country.dial}$digits';
    try {
      final r = await AuthService.instance.sendCode(e164);
      if (!mounted) return;
      setState(() => _sending = false);
      if (r.autoSignedIn) {
        Navigator.of(context).pushAndRemoveUntil(fadeRoute<void>(const NavigatorScreen()), (_) => false);
        return;
      }
      Navigator.of(context).push(fadeRoute<void>(OtpScreen(
        phone: e164,
        display: '${_country.dial} ${_ctrl.text}',
        verificationId: r.verificationId!,
        resendToken: r.resendToken,
      )));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppToast(context, e.message);
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushAndRemoveUntil(fadeRoute<void>(const GuestHomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final focused = _focus.hasFocus;

    // Mesures de la reference (dp): ligne de base du titre 58.6 sous la barre
    // d'etat, sous-titre +33.4, champ +37.5 sous la ligne de base du sous-titre.
    final titleTop = inset + 58.6 - DmBase.dm(26.6).ascentBox;
    const titleBelow = 26.6 - 26.6 * 0.992 / 1.302;
    final subAscent = DmBase.inter(14).ascentBox;
    final gapTitleSub = 33.4 - titleBelow - subAscent;
    final gapSubField = 37.5 - (14 - subAscent);

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
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, mq.padding.bottom + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: titleTop),
                _rise(
                  _aTop,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sign in to Miam', style: dmStyle(c.title, size: 26.6, h: 1, ls: -0.84)),
                      SizedBox(height: gapTitleSub),
                      Text('Enter your phone number to continue.', style: interStyle(c.subtitle, size: 14, h: 1, ls: -0.28)),
                    ],
                  ),
                ),
                SizedBox(height: gapSubField),
                _rise(
                  _aField,
                  SizedBox(
                    height: 46,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _pickCountry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.field, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Flag(country: _country, size: 20),
                                const SizedBox(width: 9),
                                Text(_country.dial, style: interStyle(c.subtitle, size: 12.5, h: 1.2, ls: -0.2)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.6),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: focused ? Colors.transparent : c.field,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: focused ? c.primary : Colors.transparent, width: 1.2),
                            ),
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              cursorColor: c.caret,
                              inputFormatters: [_PhoneFormatter(_country.pattern)],
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _send(),
                              style: interStyle(c.title, size: 16, h: 1.2, ls: -0.3),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: focused ? null : 'Phone number',
                                hintStyle: interStyle(c.subtitle, size: 16, h: 1.2, ls: -0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                _rise(
                  _aBottom,
                  Column(
                    children: [
                      LoadingButton(
                        label: 'Send Code',
                        loading: _sending,
                        onTap: _valid ? _send : null,
                      ),
                      const SizedBox(height: 16),
                      _SkipButton(onTap: _skip, locked: _sending),
                    ],
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

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap, required this.locked});
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: locked ? null : onTap,
      child: AnimatedOpacity(
        opacity: locked ? 0.4 : 1,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Center(child: Text('Skip for now', style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.3))),
        ),
      ),
    );
  }
}

/// Drapeau rond (bandes de couleur), avec fin liseré pour le fond clair.
class _Flag extends StatelessWidget {
  const _Flag({required this.country, required this.size});
  final _Country country;
  final double size;

  Widget _face() {
    final s = country.stripes;
    switch (country.kind) {
      case _FlagKind.vertical:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final col in s) Expanded(child: ColoredBox(color: col))],
        );
      case _FlagKind.horizontal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final col in s) Expanded(child: ColoredBox(color: col))],
        );
      case _FlagKind.benin:
        // Vert a gauche, jaune au-dessus du rouge a droite.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: ColoredBox(color: s[0])),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ColoredBox(color: s[1])),
                  Expanded(child: ColoredBox(color: s[2])),
                ],
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = MiamColors.of(context).outline;
    final dot = country.dot;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: line.withValues(alpha: 0.5), width: 0.6)),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _face(),
            if (dot != null)
              Center(
                child: Container(
                  width: size * 0.34,
                  height: size * 0.34,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _fold(String v) => v
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâä]'), 'a')
    .replaceAll('ô', 'o')
    .replaceAll('î', 'i')
    .replaceAll('ç', 'c')
    .replaceAll("'", '')
    .replaceAll('’', '');

/// Selecteur de pays (reference): grande feuille avec drapeau + croix en haut,
/// titre, champ de recherche, puis la liste (drapeau, nom, indicatif, radio).
class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.selected});
  final _Country selected;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  static const double _rowH = 72.2;
  final _q = TextEditingController();
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: math.max(0, _countries.indexOf(widget.selected) - 2) * _rowH,
  );

  @override
  void dispose() {
    _q.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<_Country> get _items {
    final q = _fold(_q.text.trim());
    if (q.isEmpty) return _countries;
    return [
      for (final k in _countries)
        if (_fold(k.name).contains(q) || k.dial.contains(q)) k,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    // Le haut de la feuille est a 48.7 dp sous la barre d'etat (releve).
    final sheetH = mq.size.height - (mq.padding.top + 48.7);
    final ring = p.dark ? const Color(0xFFBDBDBD) : const Color(0xFF8F8F8F);
    final items = _items;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: sheetH,
        child: Padding(
          padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    Positioned(
                      top: 22.3,
                      left: 0,
                      right: 0,
                      child: Center(child: Icon(AppIcons.flag, size: 24, color: c.title)),
                    ),
                    Positioned(
                      top: 12.3,
                      right: 8.2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(child: Icon(AppIcons.closeCircle, size: 21.5, color: c.title)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70.1,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text('Select country code', style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.3)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.only(left: 7.7, right: 12),
                decoration: BoxDecoration(color: c.field, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(AppIcons.search, size: 24, color: c.subtitle),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _q,
                        onChanged: (_) => setState(() {}),
                        cursorColor: c.caret,
                        textInputAction: TextInputAction.search,
                        style: interStyle(c.title, size: 14, h: 1.2, ls: -0.3),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Search country name',
                          hintStyle: interStyle(c.subtitle, size: 14, h: 1.2, ls: -0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text('No country found', style: interStyle(c.subtitle, size: 14, h: 1.2, ls: -0.3)))
                    : ListView.builder(
                        controller: _scroll,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(16, 3.7, 16, mq.padding.bottom + 8),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final k = items[i];
                          final on = k == widget.selected;
                          return InkWell(
                            splashFactory: NoSplash.splashFactory,
                            highlightColor: p.tile,
                            onTap: () => Navigator.of(context).pop(k),
                            child: Container(
                              height: _rowH,
                              padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
                              decoration: BoxDecoration(
                                border: i == items.length - 1 ? null : Border(bottom: BorderSide(color: p.line, width: 1.2)),
                              ),
                              child: Row(
                                children: [
                                  _Flag(country: k, size: 32),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(k.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.3)),
                                        const SizedBox(height: 6.5),
                                        Text(k.dial, style: interStyle(p.mutedText, size: 12, h: 1.2, ls: -0.2)),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: on ? c.title : ring, width: 1.8),
                                    ),
                                    child: Center(
                                      child: AnimatedScale(
                                        scale: on ? 1 : 0,
                                        duration: const Duration(milliseconds: 160),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(color: c.title, shape: BoxShape.circle),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
