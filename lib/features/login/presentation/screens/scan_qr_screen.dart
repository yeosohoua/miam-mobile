// PATCH-9
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const _inter = 'packages/miam_assets/Inter';
const _dmSans = 'packages/miam_assets/DM Sans';

/// Ecran de scan QR. Retourne (pop) le code de 5 caracteres detecte, ou null.
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  static Route<String> route() => PageRouteBuilder<String>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => const ScanQrScreen(),
        transitionsBuilder: (_, a, __, child) {
          final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      );

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Extrait un code de 5 caracteres (A-Z0-9) d'un QR : URL (?code=, dernier segment) ou texte brut.
  String? _extract(String raw) {
    final up = raw.trim();
    final uri = Uri.tryParse(up);
    final cands = <String>[
      if (uri != null) ...[
        ...uri.queryParameters.values,
        ...uri.pathSegments.reversed,
      ],
      up,
    ];
    for (final s in cands) {
      final t = s.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
      if (t.length >= 3 && t.length <= 5) return t;
    }
    final all = up.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    return all.length >= 5 ? all.substring(0, 5) : null;
  }

  void _onDetect(BarcodeCapture cap) {
    if (_done) return;
    for (final b in cap.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final code = _extract(raw);
      if (code == null) continue;
      _done = true;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              top: top + 50,
              child: MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                onDetect: _onDetect,
                errorBuilder: (ctx, e) => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Camera access is needed to scan a QR code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: _inter, fontSize: 14.1, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            // Cadre de visee : 248 dp, centre dans la zone camera.
            Positioned.fill(
              top: top + 50,
              child: const Center(child: _ScanFrame()),
            ),
            // Texte d'aide (centre a ~732 dp sur 823).
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom + 74,
              child: const Text(
                'Point your camera at the QR code on your invite',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _inter,
                  fontSize: 14.1,
                  height: 1.2,
                  letterSpacing: -0.3,
                  color: Color(0xDDFFFFFF),
                ),
              ),
            ),
            // Barre noire du haut.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(top: top),
                height: top + 50,
                child: Row(
                  children: [
                    InkResponse(
                      radius: 24,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const SizedBox(
                        width: 56,
                        height: 50,
                        child: Icon(Icons.close, size: 26, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan QR code',
                      style: TextStyle(
                        fontFamily: _dmSans,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      height: 248,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xD9FFFFFF), width: 1.6),
      ),
    );
  }
}
