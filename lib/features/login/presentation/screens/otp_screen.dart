// PATCH-27
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/router/fade_route.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../navigator/presentation/screens/navigator_screen.dart';

const int _kLen = 6;
const int _kResendSeconds = 30;

/// Saisie du code SMS (6 chiffres): meme style que l'ecran telephone.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.display, required this.verificationId, this.resendToken});
  final String phone; // E.164
  final String display; // "+225 07 12 34 56 78"
  final String verificationId;
  final int? resendToken;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  StreamSubscription<void>? _autoSub;
  Timer? _timer;

  late String _verificationId = widget.verificationId;
  int? _resendToken;
  int _left = _kResendSeconds;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resendToken = widget.resendToken;
    _focus.addListener(() => setState(() {}));
    _startTimer();
    // Android peut lire le SMS et connecter l'utilisateur sans saisie.
    _autoSub = AuthService.instance.autoSignedIn.listen((_) => _done());
  }

  @override
  void dispose() {
    _autoSub?.cancel();
    _timer?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    _intro.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = _kResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left = math.max(0, _left - 1));
      if (_left == 0) t.cancel();
    });
  }

  void _done() {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(fadeRoute<void>(const NavigatorScreen()), (_) => false);
  }

  Future<void> _verify() async {
    if (_verifying || _ctrl.text.length != _kLen) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await AuthService.instance.confirmCode(_verificationId, _ctrl.text);
      if (!mounted) return;
      _done();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _verifying = false;
        _error = e.message;
      });
      _ctrl.clear();
      _shake.forward(from: 0);
      _focus.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_resending || _left > 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final r = await AuthService.instance.sendCode(widget.phone, resendToken: _resendToken);
      if (!mounted) return;
      if (r.autoSignedIn) return _done();
      _verificationId = r.verificationId ?? _verificationId;
      _resendToken = r.resendToken ?? _resendToken;
      _ctrl.clear();
      setState(() => _resending = false);
      _startTimer();
      showAppToast(context, 'Code sent');
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _resending = false);
      showAppToast(context, e.message);
    }
  }

  Widget _rise(double a, double b, Widget child) {
    final anim = CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(anim), child: child),
    );
  }

  String get _timeLabel {
    final m = _left ~/ 60;
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final code = _ctrl.text;
    final titleTop = inset + 96.6 - DmBase.dm(26.6).ascentBox;

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
          child: Stack(
            children: [
              Positioned(
                top: inset + 10,
                left: 8,
                width: 56,
                height: 44,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _verifying ? null : () => Navigator.of(context).maybePop(),
                  child: Center(child: Icon(AppIcons.arrowLeft, size: 24, color: c.title)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, mq.padding.bottom + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: titleTop),
                    _rise(
                      0.0,
                      0.55,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verify your number', style: dmStyle(c.title, size: 26.6, h: 1, ls: -0.84)),
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              text: 'Enter the 6-digit code we sent to ',
                              style: interStyle(c.subtitle, size: 14, h: 1.35, ls: -0.28),
                              children: [TextSpan(text: widget.display, style: interStyle(c.title, size: 14, w: FontWeight.w500, h: 1.35, ls: -0.28))],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _rise(
                      0.2,
                      0.75,
                      AnimatedBuilder(
                        animation: _shake,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(math.sin(_shake.value * math.pi * 6) * 9 * (1 - _shake.value), 0),
                          child: child,
                        ),
                        child: SizedBox(
                          height: 54,
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  for (var i = 0; i < _kLen; i++) ...[
                                    if (i > 0) const SizedBox(width: 8),
                                    Expanded(child: _Box(char: i < code.length ? code[i] : '', active: _focus.hasFocus && i == math.min(code.length, _kLen - 1), error: _error != null)),
                                  ],
                                ],
                              ),
                              // Champ reel (invisible) qui recoit la saisie / l'auto-remplissage SMS.
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0,
                                  child: TextField(
                                    controller: _ctrl,
                                    focusNode: _focus,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.oneTimeCode],
                                    enableInteractiveSelection: false,
                                    showCursor: false,
                                    maxLength: _kLen,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                                    onChanged: (v) {
                                      setState(() => _error = null);
                                      if (v.length == _kLen) _verify();
                                    },
                                    onSubmitted: (_) => _verify(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.topLeft,
                      child: _error == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(_error!, style: interStyle(c.error, size: 12.5, h: 1.3, ls: -0.2)),
                            ),
                    ),
                    const SizedBox(height: 22),
                    _rise(
                      0.3,
                      0.9,
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _left == 0 && !_resending ? _resend : null,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _left > 0
                              ? Text.rich(
                                  key: const ValueKey('wait'),
                                  TextSpan(
                                    text: "Didn't get the code? ",
                                    style: interStyle(c.subtitle, size: 13.5, h: 1.3, ls: -0.25),
                                    children: [TextSpan(text: 'Resend in $_timeLabel', style: interStyle(c.title, size: 13.5, w: FontWeight.w500, h: 1.3, ls: -0.25))],
                                  ),
                                )
                              : Text(
                                  _resending ? 'Sending…' : 'Resend code',
                                  key: ValueKey(_resending),
                                  style: interStyle(c.title, size: 13.5, w: FontWeight.w500, h: 1.3, ls: -0.25).copyWith(decoration: TextDecoration.underline),
                                ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _rise(
                      0.4,
                      1.0,
                      LoadingButton(label: 'Verify', loading: _verifying, onTap: code.length == _kLen ? _verify : null),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.char, required this.active, required this.error});
  final String char;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = AppPalette(context).c;
    final Color border = error ? c.error : (active ? c.primary : Colors.transparent);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.transparent : c.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Text(char, style: interStyle(c.title, size: 22, w: FontWeight.w500, h: 1, ls: 0)),
    );
  }
}
