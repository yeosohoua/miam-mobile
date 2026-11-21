// PATCH-12 PATCH-13
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_button.dart';
import 'blur_sheet.dart';

const _inter = 'packages/miam_assets/Inter';
const _dmSans = 'packages/miam_assets/DM Sans';

/// Donnees de la marketplace trouvee a partir du code.
class MarketplaceInfo {
  const MarketplaceInfo({required this.name, required this.description, this.logoUrl, this.token});
  final String name;
  final String description;

  /// Logo de l'etablissement (null : carre gris) et jeton de la connexion en attente pour le charger.
  final String? logoUrl;
  final String? token;
}

/// Bottom sheet "Is this your marketplace?".
/// Retourne true (Yes, continue), false (No, try another code) ou null (ferme).
Future<bool?> showMarketplaceConfirmSheet(BuildContext context, MarketplaceInfo info) =>
    showBlurSheet<bool>(context, child: _ConfirmContent(info: info));

class _ConfirmContent extends StatefulWidget {
  const _ConfirmContent({required this.info});
  final MarketplaceInfo info;

  @override
  State<_ConfirmContent> createState() => _ConfirmContentState();
}

class _ConfirmContentState extends State<_ConfirmContent> {
  bool _loading = false;

  Future<void> _yes() async {
    if (_loading) return;
    HapticFeedback.selectionClick();
    setState(() => _loading = true);
    // TODO: rejoindre la marketplace aupres de l'API (a brancher plus tard).
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final c = MiamColors.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    TextStyle label(Color color) => TextStyle(
          fontFamily: _inter,
          fontWeight: FontWeight.w500,
          fontSize: 14.1,
          height: 1.2,
          letterSpacing: -0.4,
          color: color,
          decoration: TextDecoration.none,
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Is this your marketplace?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _inter,
              fontWeight: FontWeight.w500,
              fontSize: 13.4,
              height: 1.5,
              letterSpacing: -0.2,
              color: c.title,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 36),
          _EtabLogo(url: info.logoUrl, token: info.token),
          const SizedBox(height: 14),
          Text(
            info.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _dmSans,
              fontWeight: FontWeight.w500,
              fontSize: 22,
              height: 1.27,
              letterSpacing: -0.7,
              color: c.title,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            info.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _inter,
              fontSize: 13.4,
              height: 1.5,
              letterSpacing: -0.2,
              color: c.subtitle,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 32),
          LoadingButton(label: 'Yes, continue', loading: _loading, onTap: _yes),
          const SizedBox(height: 8.4),
          AnimatedOpacity(
            opacity: _loading ? 0.4 : 1,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: _loading,
              child: _Btn(
                height: 46,
                fill: Colors.transparent,
                border: c.outline,
                child: Text('No, try another code', style: label(c.title)),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can switch later.',
            style: TextStyle(
              fontFamily: _inter,
              fontSize: 12,
              height: 1.3,
              letterSpacing: -0.2,
              color: c.subtitle,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo de l'etablissement ; carre gris s'il n'en a pas ou s'il ne se charge pas.
class _EtabLogo extends StatelessWidget {
  const _EtabLogo({this.url, this.token});
  final String? url;
  final String? token;

  static const _gris = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    final u = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        height: 72,
        child: ColoredBox(
          color: _gris,
          child: (u == null || u.isEmpty)
              ? null
              : Image.network(
                  u,
                  fit: BoxFit.cover,
                  headers: token == null ? null : {'Authorization': 'Bearer $token'},
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  const _Btn({required this.height, required this.fill, required this.border, required this.child, required this.onTap});
  final double height;
  final Color fill;
  final Color? border;
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: double.infinity,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: BorderRadius.circular(12),
              border: widget.border == null ? null : Border.all(color: widget.border!),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Logo en anneau de tirets (blanc sur fond noir).
class _RingLogoPainter extends CustomPainter {
  const _RingLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ctr = size.center(Offset.zero);
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    const n = 24;
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      final outer = 24.5;
      final inner = i.isEven ? 15.5 : 17.5;
      final half = 0.115;
      final path = Path()
        ..moveTo(ctr.dx + math.cos(a - half * 0.55) * inner, ctr.dy + math.sin(a - half * 0.55) * inner)
        ..lineTo(ctr.dx + math.cos(a - half) * outer, ctr.dy + math.sin(a - half) * outer)
        ..lineTo(ctr.dx + math.cos(a + half) * outer, ctr.dy + math.sin(a + half) * outer)
        ..lineTo(ctr.dx + math.cos(a + half * 0.55) * inner, ctr.dy + math.sin(a + half * 0.55) * inner)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
