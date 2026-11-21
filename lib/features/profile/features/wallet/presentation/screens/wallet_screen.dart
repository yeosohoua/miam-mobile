import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/api/erp_api.dart';
import '../../../../../../core/api/erp_stores.dart';
import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../core/widgets/icon_tile.dart';
import '../widgets/wallet_sheets.dart';

/// Portefeuille : carte avec le QR de la personne, solde en FCFA, carte cadeau, recharge Paystack.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with WidgetsBindingObserver {
  final _store = WalletStore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _store.addListener(_maj);
    _store.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _store.removeListener(_maj);
    super.dispose();
  }

  void _maj() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed && paiementEnAttente != null) _verifier();
  }

  Future<void> _verifier() async {
    final ref = paiementEnAttente;
    if (ref == null) return;
    try {
      final r = await ErpApi.verifier(ref);
      if (r.enAttente) return;
      paiementEnAttente = null;
      await _store.load();
      if (mounted) showAppToast(context, r.credite ? 'Recharge effectuée. Solde mis à jour.' : (r.message.isNotEmpty ? r.message : 'Paiement non abouti.'));
    } on ApiException {
      // On reessaiera a la prochaine reprise.
    }
  }

  String _role(String r) => switch (r) { 'PARENT' => 'Parent', 'ELEVE' => 'Élève', 'EMPLOYE' => 'Employé', _ => '' };

  void _ouvrirRecharge({required bool methode}) {
    HapticFeedback.selectionClick();
    final w = _store.data;
    final id = _store.inscritId;
    if (w == null) return;
    if (id == null) {
      showAppToast(context, 'Aucun compte prépayé à recharger.');
      return;
    }
    showRechargeSheet(context, choisirMethode: methode, inscritId: id, wallet: w);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final w = _store.data;
    final compte = _store.compte;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, mq.padding.top + 14, 16, 78.8 + mq.padding.bottom + 31.3),
          child: Column(
            children: [
              SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('Portefeuille', style: dmStyle(c.title, size: 15.5, ls: -0.45)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pushNamed('/transactions'),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                          child: Icon(AppIcons.clock, size: 24, color: c.title),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _store.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      if (w != null && w.comptes.length > 1) ...[
                        SizedBox(
                          height: 34,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: w.comptes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final sel = i == _store.index;
                              return GestureDetector(
                                onTap: () => _store.select(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: sel ? c.primary : p.chipNeutral, borderRadius: BorderRadius.circular(10)),
                                  child: Text(w.comptes[i].nom.split(' ').first, style: interStyle(sel ? c.onPrimary : c.title, size: 13.4, w: FontWeight.w500)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _CarteSolde(
                        qr: _store.qr,
                        nom: compte?.nom ?? w?.nom ?? '',
                        role: _role(w?.role ?? ''),
                        solde: compte == null ? null : compte.solde,
                        chargement: _store.loading && w == null,
                      ),
                      if (_store.error != null && w == null)
                        Padding(padding: const EdgeInsets.only(top: 12), child: Text(_store.error!, style: interStyle(c.error, size: 13))),
                      const SizedBox(height: 21.3),
                      _Ligne(
                        icon: AppIcons.gift,
                        label: 'Utiliser une carte cadeau',
                        onTap: () {
                          final id = _store.inscritId;
                          if (id == null) {
                            showAppToast(context, 'Aucun compte prépayé à créditer.');
                            return;
                          }
                          showGiftCardSheet(context, inscritId: id);
                        },
                      ),
                      const SizedBox(height: 21),
                      Divider(height: 1, thickness: 1, color: p.divider),
                      const SizedBox(height: 17),
                      Text('Moyen de paiement', style: dmStyle(c.title, size: 15.4, w: FontWeight.w600, ls: -0.4)),
                      const SizedBox(height: 15.3),
                      _Ligne(icon: AppIcons.card, label: 'Ajouter un moyen de paiement', onTap: () => _ouvrirRecharge(methode: true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _BoutonCredit(onTap: () => _ouvrirRecharge(methode: false)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppPalette(context).c;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.3),
        child: Row(children: [
          IconTile(icon: icon),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: interStyle(c.title, size: 14.1))),
        ]),
      ),
    );
  }
}

class _CarteSolde extends StatelessWidget {
  const _CarteSolde({required this.qr, required this.nom, required this.role, required this.solde, required this.chargement});
  final String qr, nom, role;
  final int? solde;
  final bool chargement;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _BlueCardPainter())),
            Positioned(
              left: 16,
              top: 14,
              child: Image.asset('assets/images/miam_logo.png', height: 40, width: 40, errorBuilder: (_, __, ___) => const SizedBox(height: 40, width: 40)),
            ),
            if (role.isNotEmpty)
              Positioned(
                right: 16,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(20)),
                  child: Text(role, style: interStyle(Colors.black, size: 12, w: FontWeight.w500)),
                ),
              ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 156,
                  height: 156,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: qr.isEmpty
                      ? Center(child: chargement ? const CircularProgressIndicator(strokeWidth: 2) : Text('QR indisponible', textAlign: TextAlign.center, style: interStyle(Colors.black54, size: 12)))
                      : QrImageView(data: qr, version: QrVersions.auto, padding: EdgeInsets.zero, backgroundColor: Colors.white),
                ),
              ),
            ),
            Positioned(left: 16, bottom: 44, child: Text(solde == null ? nom : 'Solde total', style: interStyle(Colors.black, size: 12))),
            Positioned(
              left: 16,
              bottom: 12,
              child: Text(solde == null ? '' : fcfa(solde!), style: dmStyle(Colors.black, size: 26.3, h: 1.25, ls: -1)),
            ),
            if (solde != null && nom.isNotEmpty)
              Positioned(right: 16, bottom: 14, child: Text(nom, style: interStyle(Colors.black, size: 12.4, w: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}

class _BlueCardPainter extends CustomPainter {
  const _BlueCardPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF02A6F0), Color(0xFF0394DE)]).createShader(rect),
    );
    final wave = Path()
      ..moveTo(0, s.height * 0.52)
      ..cubicTo(s.width * 0.20, s.height * 0.40, s.width * 0.34, s.height * 0.22, s.width * 0.46, s.height * 0.26)
      ..cubicTo(s.width * 0.62, s.height * 0.31, s.width * 0.74, s.height * 0.58, s.width * 0.86, s.height * 0.57)
      ..cubicTo(s.width * 0.94, s.height * 0.56, s.width * 0.98, s.height * 0.40, s.width, s.height * 0.32)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(wave, Paint()..color = const Color(0x2EFFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BoutonCredit extends StatefulWidget {
  const _BoutonCredit({required this.onTap});
  final VoidCallback onTap;
  @override
  State<_BoutonCredit> createState() => _BoutonCreditState();
}

class _BoutonCreditState extends State<_BoutonCredit> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = AppPalette(context).c;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: Container(
          height: 44,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(AppIcons.plusCircle, size: 20, color: c.onPrimary),
            const SizedBox(width: 14),
            Text('Ajouter du crédit', style: interStyle(c.onPrimary, size: 14, w: FontWeight.w500, h: 1.2, ls: -0.3)),
          ]),
        ),
      ),
    );
  }
}
