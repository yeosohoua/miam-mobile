import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/api/erp_api.dart';
import '../../../../../../core/api/erp_stores.dart';
import '../../../../../../core/theme/app_icons.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../core/widgets/loading_button.dart';
import '../../../../../login/presentation/widgets/blur_sheet.dart';

/// Reference Paystack en attente de verification (a la reprise de l'application).
String? paiementEnAttente;

Widget _poignee(AppPalette p) => Center(
      child: Container(margin: const EdgeInsets.only(top: 10, bottom: 14), width: 38, height: 4, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(2))),
    );

Widget _titre(AppPalette p, String t, {String? sous}) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: dmStyle(p.c.title, size: 18, w: FontWeight.w600, ls: -0.5)),
        if (sous != null) ...[const SizedBox(height: 6), Text(sous, style: interStyle(p.mutedText, size: 13.2))],
      ]),
    );

/// Carte cadeau : saisie du code dans une feuille a fond flou.
Future<bool?> showGiftCardSheet(BuildContext context, {required String inscritId}) =>
    showBlurSheet<bool>(context, child: _GiftSheet(inscritId: inscritId));

class _GiftSheet extends StatefulWidget {
  const _GiftSheet({required this.inscritId});
  final String inscritId;
  @override
  State<_GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<_GiftSheet> {
  final _ctl = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final m = await ErpApi.carteCadeau(widget.inscritId, _ctl.text.trim());
      await WalletStore.instance.load();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppToast(context, m);
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _poignee(p),
          _titre(p, 'Utiliser une carte cadeau', sous: 'Saisissez le code de votre carte pour créditer le compte.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _ctl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              cursorColor: c.caret,
              style: interStyle(c.title, size: 16, w: FontWeight.w500, ls: 1.2),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\- ]')), LengthLimitingTextInputFormatter(20)],
              onChanged: (_) => setState(() => _err = null),
              decoration: InputDecoration(
                hintText: 'XXXX-XXXX-XXXX',
                hintStyle: interStyle(p.mutedText, size: 16),
                filled: true,
                fillColor: p.tile,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.title)),
              ),
            ),
          ),
          if (_err != null) Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Text(_err!, style: interStyle(c.error, size: 12.6))),
          const SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + mq.padding.bottom),
            child: LoadingButton(label: 'Valider la carte', loading: _busy, onTap: _ctl.text.trim().length >= 8 && !_busy ? _go : null),
          ),
        ]),
      ),
    );
  }
}

/// Recharge : [choisirMethode] = true affiche d'abord le choix du moyen (Paystack), puis le montant.
Future<void> showRechargeSheet(BuildContext context, {required bool choisirMethode, required String inscritId, required WalletData wallet}) =>
    showBlurSheet<void>(context, child: _RechargeSheet(choisirMethode: choisirMethode, inscritId: inscritId, wallet: wallet));

class _RechargeSheet extends StatefulWidget {
  const _RechargeSheet({required this.choisirMethode, required this.inscritId, required this.wallet});
  final bool choisirMethode;
  final String inscritId;
  final WalletData wallet;
  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  static const _montants = [1000, 2000, 5000, 10000, 20000, 50000];
  late bool _etapeMethode = widget.choisirMethode;
  int? _montant = 5000;
  final _libre = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _libre.dispose();
    super.dispose();
  }

  int? get _valeur => _libre.text.isNotEmpty ? int.tryParse(_libre.text) : _montant;

  Future<void> _payer() async {
    final v = _valeur;
    final w = widget.wallet;
    if (v == null || v < w.min || v > w.max) {
      setState(() => _err = 'Le montant doit être compris entre ${fcfa(w.min)} et ${fcfa(w.max)}.');
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final r = await ErpApi.recharge(widget.inscritId, v);
      paiementEnAttente = r.reference;
      final ok = await launchUrl(Uri.parse(r.url), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() => _err = "Impossible d'ouvrir la page de paiement.");
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    if (!widget.wallet.rechargeActive) {
      return Padding(
        padding: EdgeInsets.only(bottom: 24 + mq.padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _poignee(p),
          _titre(p, 'Recharge indisponible', sous: "Le paiement en ligne n'est pas activé pour cet établissement. Rechargez en caisse."),
        ]),
      );
    }
    if (_etapeMethode) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20 + mq.padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _poignee(p),
          _titre(p, 'Moyen de paiement', sous: 'Choisissez comment recharger le compte.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _etapeMethode = false),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line)),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF0BA4DB), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(AppIcons.card, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Paystack', style: interStyle(c.title, size: 15, w: FontWeight.w600)),
                      Text('Carte bancaire ou Mobile Money', style: interStyle(p.mutedText, size: 12.6)),
                    ]),
                  ),
                  Icon(AppIcons.chevronRight, size: 20, color: c.title),
                ]),
              ),
            ),
          ),
        ]),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _poignee(p),
          _titre(p, 'Ajouter du crédit', sous: 'Choisissez ou saisissez un montant, puis payez avec Paystack.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in _montants)
                GestureDetector(
                  onTap: () => setState(() {
                    _montant = m;
                    _libre.clear();
                    _err = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _libre.text.isEmpty && _montant == m ? c.primary : p.chipNeutral,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(fcfa(m), style: interStyle(_libre.text.isEmpty && _montant == m ? c.onPrimary : c.title, size: 14, w: FontWeight.w500)),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: TextField(
              controller: _libre,
              keyboardType: TextInputType.number,
              cursorColor: c.caret,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
              style: interStyle(c.title, size: 16, w: FontWeight.w500),
              onChanged: (_) => setState(() => _err = null),
              decoration: InputDecoration(
                hintText: 'Autre montant (F)',
                hintStyle: interStyle(p.mutedText, size: 15),
                filled: true,
                fillColor: p.tile,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.title)),
              ),
            ),
          ),
          if (_err != null) Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Text(_err!, style: interStyle(c.error, size: 12.6))),
          const SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + mq.padding.bottom),
            child: LoadingButton(
              label: _valeur == null ? 'Payer avec Paystack' : 'Payer ${fcfa(_valeur!)} avec Paystack',
              loading: _busy,
              onTap: _valeur != null && !_busy ? _payer : null,
            ),
          ),
        ]),
      ),
    );
  }
}
