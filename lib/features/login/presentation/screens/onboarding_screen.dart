// PATCH-8 PATCH-9 PATCH-12: mise en page calee au pixel sur les captures de reference.
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_session.dart';
import '../widgets/join_code_help_sheet.dart';
import '../widgets/marketplace_confirm_sheet.dart';
import 'scan_qr_screen.dart';
import 'signed_in_screen.dart';

const _inter = 'packages/miam_assets/Inter';
const _dmSans = 'packages/miam_assets/DM Sans';

/// Ecran "Join your local marketplace".
///
/// Tailles et espacements mesures sur les captures de l'app d'origine
/// (largeur 384 dp): titre 26.6, texte et boutons 14.1, cases 62x66,
/// contenu ancre en bas, photo qui occupe l'espace restant.
/// Clavier: l'ecran est fixe (pas de defilement); tout le contenu monte
/// pour garder "Continue" juste au-dessus du clavier.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  static const _length = 5;
  static const _minLength = 3;
  static const _keyboardGap = 16.3;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _ctaKey = GlobalKey();
  final _menu = ContextMenuController();

  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  late final AnimationController _caret =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..repeat(reverse: true);

  String? _error;
  bool _loading = false;
  String? _erreurLookup;
  ErpLogin? _pending;
  int _lastLength = 0;
  double _ctaBottom = 0; // bas de "Continue" sans decalage
  double _appliedShift = 0; // decalage actuellement applique

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    // Pas de focus automatique: le clavier s'ouvre au toucher des cases.
    _intro.forward();
  }

  @override
  void dispose() {
    _menu.remove();
    _controller.dispose();
    _focus.dispose();
    _intro.dispose();
    _shake.dispose();
    _caret.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted) return;
    final box = _ctaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy + _appliedShift;
    if ((bottom - _ctaBottom).abs() > 0.5) setState(() => _ctaBottom = bottom);
  }

  void _onChanged(String value) {
    if (value.length != _lastLength) HapticFeedback.selectionClick();
    _lastLength = value.length;
    setState(() => _error = null);
  }

  Future<void> _paste() async {
    if (_loading) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final cleaned = (data?.text ?? '').toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (cleaned.isEmpty) return;
    final v = cleaned.length > _length ? cleaned.substring(0, _length) : cleaned;
    _controller.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    _lastLength = v.length;
    HapticFeedback.mediumImpact();
    setState(() => _error = null);
  }

  void _showMenu(Offset anchor) {
    _menu.show(
      context: context,
      contextMenuBuilder: (ctx) => AdaptiveTextSelectionToolbar.buttonItems(
        anchors: TextSelectionToolbarAnchors(primaryAnchor: anchor),
        buttonItems: [
          ContextMenuButtonItem(
            label: 'Paste',
            onPressed: () {
              _menu.remove();
              _paste();
            },
          ),
          ContextMenuButtonItem(
            label: 'Select all',
            onPressed: () {
              _menu.remove();
              _focus.requestFocus();
              _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _scan() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    final code = await Navigator.of(context).push<String>(ScanQrScreen.route());
    if (!mounted || code == null || code.isEmpty) return;
    final v = code.length > _length ? code.substring(0, _length) : code;
    _controller.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    setState(() => _error = null);
  }

  Future<void> _help() async {
    FocusScope.of(context).unfocus();
    final web = await showJoinCodeHelpSheet(context);
    if (!mounted || web != true) return;
    Navigator.of(context).pushNamed('/tenant-discovery');
  }

  Future<void> _continue() async {
    if (_loading || _controller.text.length < _minLength) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    // TODO: verifier le code aupres de l'API (a brancher plus tard).
    final info = await _lookup(_controller.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (info == null) {
      setState(() => _error = _erreurLookup ?? "We couldn't check the code. Check your connection and try again.");
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
      return;
    }
    final ok = await showMarketplaceConfirmSheet(context, info);
    if (!mounted) return;
    if (ok == true) {
      final p = _pending;
      if (p != null) await ErpSession.instance.adopt(p);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(fadeRoute(const SignedInScreen()), (_) => false);
    } else if (ok == false) {
      _controller.clear();
      _lastLength = 0;
      setState(() => _error = null);
    }
  }

  /// Verifie le code aupres de l'ERP : renvoie l'etablissement a confirmer (la session n'est enregistree qu'apres "Yes, continue").
  Future<MarketplaceInfo?> _lookup(String code) async {
    _erreurLookup = null;
    _pending = null;
    try {
      final r = await ErpSession.instance.authenticate(code);
      _pending = r;
      return MarketplaceInfo(name: r.etabName.isEmpty ? 'Miam' : r.etabName, description: r.description, logoUrl: r.etabLogo, token: r.token);
    } on ApiException catch (e) {
      _erreurLookup = e.message;
      return null;
    } catch (_) {
      return null;
    }
  }

  Widget _in(double begin, double end, Widget child) {
    final a = CurvedAnimation(parent: _intro, curve: Interval(begin, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(a),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final h = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final shift = keyboard <= 0 ? 0.0 : math.max(0.0, _ctaBottom + _keyboardGap - (h - keyboard));
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    final overlay = (Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    );

    return MediaQuery.withNoTextScaling(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          backgroundColor: c.background,
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: h,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: shift),
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    builder: (context, v, child) {
                      _appliedShift = v;
                      return Transform.translate(offset: Offset(0, -v), child: child);
                    },
                    child: _page(c),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _page(MiamColors c) {
    final code = _controller.text;
    final ready = code.length >= _minLength && !_loading;
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La photo occupe tout l'espace libre au-dessus du contenu.
        Expanded(
          child: ClipRect(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _intro, curve: const Interval(0, 0.55, curve: Curves.easeOut)),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.08, end: 1).animate(
                  CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/onboarding.webp', fit: BoxFit.cover, alignment: Alignment.topCenter),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.68, 1.0],
                          colors: [c.background.withValues(alpha: 0), c.background],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10.7, 16, 4 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _in(
                0.25,
                0.7,
                Text(
                  'Join your local marketplace',
                  style: TextStyle(
                    fontFamily: _dmSans,
                    fontWeight: FontWeight.w500,
                    fontSize: 26.6,
                    height: 1.2,
                    letterSpacing: -0.84,
                    color: c.title,
                  ),
                ),
              ),
              const SizedBox(height: 12.1),
              _in(
                0.35,
                0.8,
                Text(
                  'Enter the join code from its website, a poster or your invite — 5 characters, like K7MBP.',
                  style: TextStyle(fontFamily: _inter, fontSize: 14.1, height: 1.41, letterSpacing: -0.3, color: c.subtitle),
                ),
              ),
              const SizedBox(height: 25.9),
              _in(0.45, 0.9, _buildCode(code, hasError)),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: hasError
                      ? Padding(
                          key: const ValueKey('err'),
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(Icons.error, size: 12, color: c.error),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(fontFamily: _inter, fontSize: 12, height: 1.35, letterSpacing: -0.2, color: c.error),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(key: ValueKey('noerr'), width: double.infinity),
                ),
              ),
              const SizedBox(height: 9.2),
              _in(
                0.55,
                1,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: AnimatedOpacity(
                        opacity: _loading ? 0.45 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: _TextAction(label: 'Paste code', onTap: _loading ? null : _paste),
                      ),
                    ),
                    const SizedBox(height: 16.9),
                    _Pressable(
                      onTap: ready ? _continue : null,
                      child: AnimatedContainer(
                        key: _ctaKey,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ready ? c.primary : c.disabled,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: _loading
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: CupertinoActivityIndicator(radius: 8, color: c.onDisabled.withValues(alpha: 0.8)),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: _label(ready ? c.onPrimary : c.onDisabled),
                              child: const Text('Continue'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Pressable(
                      onTap: _scan,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: c.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 20, color: c.title),
                            const SizedBox(width: 8),
                            Text('Scan QR code', style: _label(c.title)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.4),
                    Center(
                      child: _TextAction(
                        label: "I don't have a code",
                        onTap: _help,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCode(String code, bool hasError) {
    final showCaret = (_focus.hasFocus || _loading) && code.length < _length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focus.requestFocus(),
      onLongPressStart: (d) => _showMenu(d.globalPosition),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final t = _shake.value;
              final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Row(
              children: [
                for (var i = 0; i < _length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _CodeBox(
                      char: i < code.length ? code[i] : '',
                      active: showCaret && i == code.length,
                      hasError: hasError,
                      caret: _caret,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Champ reel invisible: gere clavier et saisie.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                maxLength: _length,
                showCursor: false,
                enableInteractiveSelection: false,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toUpperCase())),
                ],
                onChanged: _onChanged,
                onSubmitted: (_) => _continue(),
                decoration: const InputDecoration(counterText: '', border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _label(Color color) => TextStyle(
      fontFamily: _inter,
      fontSize: 14.1,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: -0.4,
      color: color,
    );

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.char, required this.active, required this.hasError, required this.caret});

  final String char;
  final bool active;
  final bool hasError;
  final Animation<double> caret;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    final filled = char.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? c.fieldFilled : c.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? c.error : Colors.transparent, width: 1.3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(scale: Tween<double>(begin: 0.6, end: 1).animate(a), child: child),
            ),
            child: filled
                ? Text(
                    char,
                    key: ValueKey(char),
                    style: TextStyle(
                      fontFamily: _dmSans,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.6,
                      height: 1,
                      color: hasError ? c.error : c.title,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          if (active && !filled)
            FadeTransition(
              opacity: Tween<double>(begin: 0.1, end: 1).animate(caret),
              child: Container(width: 2, height: 17, decoration: BoxDecoration(color: c.caret, borderRadius: BorderRadius.circular(1))),
            ),
        ],
      ),
    );
  }
}

/// Bouton texte avec retour tactile.
class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = MiamColors.of(context);
    return _Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(label, textAlign: TextAlign.center, style: _label(c.title)),
      ),
    );
  }
}

/// Retour tactile commun: reduit legerement l'element pendant l'appui.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
