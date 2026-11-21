import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_stores.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/sub_page.dart';

/// Validation de la commande : moyen de paiement (Paystack ou espèces), mode (sur place / à emporter), récapitulatif.
class FinalizeCartOrderScreen extends StatefulWidget {
  const FinalizeCartOrderScreen({super.key});
  @override
  State<FinalizeCartOrderScreen> createState() => _FinalizeCartOrderScreenState();
}

class _FinalizeCartOrderScreenState extends State<FinalizeCartOrderScreen> with WidgetsBindingObserver {
  final _cart = CartStore.instance;
  final _wallet = WalletStore.instance;
  String _paiement = 'ESPECES';
  String _mode = 'SUR_PLACE';
  bool _busy = false;
  String? _err;
  String? _reference; // recharge Paystack en cours

  bool get _paystackDispo {
    final w = _wallet.data;
    final c = _wallet.compte;
    return w != null && w.rechargeActive && c != null && c.prepaye;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wallet.addListener(_maj);
    _wallet.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wallet.removeListener(_maj);
    super.dispose();
  }

  void _maj() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed && _reference != null && !_busy) _apresPaiement();
  }

  Future<void> _apresPaiement() async {
    final ref = _reference;
    if (ref == null) return;
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final r = await ErpApi.verifier(ref);
      if (r.enAttente) {
        setState(() => _err = 'Paiement pas encore confirmé. Terminez-le dans Paystack puis revenez ici.');
      } else if (!r.credite) {
        _reference = null;
        setState(() => _err = r.message.isNotEmpty ? r.message : 'Paiement non abouti.');
      } else {
        _reference = null;
        await _wallet.load();
        await _commander();
        return;
      }
    } on ApiException catch (e) {
      setState(() => _err = e.message);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _confirmer() async {
    HapticFeedback.selectionClick();
    if (_cart.lines.isEmpty) return;
    setState(() {
      _busy = true;
      _err = null;
    });
    if (_paiement == 'PAYSTACK') {
      final solde = _wallet.solde ?? 0;
      final manque = _cart.total - solde;
      if (manque > 0) {
        final w = _wallet.data!;
        final montant = manque < w.min ? w.min : manque;
        if (montant > w.max) {
          setState(() {
            _busy = false;
            _err = 'Montant trop élevé pour une recharge (maximum ${fcfa(w.max)}).';
          });
          return;
        }
        try {
          final r = await ErpApi.recharge(_wallet.inscritId!, montant);
          _reference = r.reference;
          final ok = await launchUrl(Uri.parse(r.url), mode: LaunchMode.externalApplication);
          if (!ok) _err = "Impossible d'ouvrir la page de paiement.";
        } on ApiException catch (e) {
          _err = e.message;
        }
        if (mounted) setState(() => _busy = false);
        return;
      }
    }
    await _commander();
  }

  Future<void> _commander() async {
    try {
      await _cart.valider(inscritId: _wallet.inscritId, mode: _mode, paiement: _paiement);
      _wallet.load();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pushNamedAndRemoveUntil('/navigator', (_) => false);
      showAppToast(nav.context, 'Commande validée.');
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
    if (mounted) setState(() => _busy = false);
  }

  Widget _radio(AppPalette p, bool sel) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? p.c.primary : Colors.transparent, border: Border.all(color: sel ? p.c.primary : p.mutedText, width: 1.6)),
        child: sel ? Icon(AppIcons.check, size: 16, color: p.c.onPrimary) : null,
      );

  Widget _option(AppPalette p, {required IconData icon, required String titre, String? sous, required bool sel, required VoidCallback onTap}) {
    final c = p.c;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? c.title : p.line, width: sel ? 1.6 : 1)),
        child: Row(children: [
          _radio(p, sel),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line)),
            child: Icon(icon, size: 24, color: c.title),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titre, style: interStyle(c.title, size: 15, w: FontWeight.w500)),
              if (sous != null) Text(sous, style: interStyle(p.mutedText, size: 12.6)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _carte(AppPalette p, {required String titre, required List<Widget> enfants}) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titre, style: interStyle(p.c.title, size: 15, w: FontWeight.w500)),
          const SizedBox(height: 12),
          ...enfants,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final dispo = _paystackDispo;
    if (!dispo && _paiement == 'PAYSTACK') _paiement = 'ESPECES';
    final solde = _wallet.solde ?? 0;
    final manque = _paiement == 'PAYSTACK' ? _cart.total - solde : 0;

    String label = 'Confirmer · ${fcfa(_cart.total)}';
    if (_reference != null) {
      label = 'Vérifier mon paiement';
    } else if (_paiement == 'PAYSTACK' && manque > 0) {
      label = 'Payer avec Paystack';
    }

    return SubPage(
      title: 'Commande et paiement',
      scrollable: false,
      child: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), children: [
            _carte(p, titre: 'Choisir le moyen de paiement', enfants: [
              if (dispo)
                _option(p,
                    icon: AppIcons.card,
                    titre: 'Paystack',
                    sous: 'Carte ou Mobile Money · solde ${fcfa(solde)}',
                    sel: _paiement == 'PAYSTACK',
                    onTap: _busy ? () {} : () => setState(() => _paiement = 'PAYSTACK')),
              _option(p, icon: Icons.payments_outlined, titre: 'Espèces', sous: 'À régler en caisse', sel: _paiement == 'ESPECES', onTap: _busy ? () {} : () => setState(() => _paiement = 'ESPECES')),
            ]),
            _carte(p, titre: 'Mode de retrait', enfants: [
              _option(p, icon: Icons.restaurant_outlined, titre: 'Manger sur place', sel: _mode == 'SUR_PLACE', onTap: () => setState(() => _mode = 'SUR_PLACE')),
              _option(p, icon: AppIcons.bag, titre: 'À emporter', sel: _mode == 'A_EMPORTER', onTap: () => setState(() => _mode = 'A_EMPORTER')),
            ]),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
              child: Column(children: [
                Align(alignment: Alignment.centerLeft, child: Text('Récapitulatif', style: interStyle(c.title, size: 16, w: FontWeight.w500))),
                const SizedBox(height: 12),
                _ligneRecap(p, 'Articles', '${_cart.count}'),
                _ligneRecap(p, 'Sous-total', fcfa(_cart.total)),
                if (manque > 0) _ligneRecap(p, 'Solde du portefeuille', fcfa(solde)),
                const SizedBox(height: 6),
                _ligneRecap(p, 'Total', fcfa(_cart.total), fort: true),
              ]),
            ),
            if (_paiement == 'PAYSTACK' && manque > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Votre solde est insuffisant : ${fcfa(manque < (_wallet.data?.min ?? 0) ? _wallet.data!.min : manque)} seront rechargés via Paystack, puis la commande sera payée avec votre portefeuille.',
                    style: interStyle(p.mutedText, size: 12.6)),
              ),
            if (_err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_err!, style: interStyle(c.error, size: 12.8))),
          ]),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 12 + mq.padding.bottom),
          child: LoadingButton(label: label, loading: _busy, onTap: _busy || _cart.lines.isEmpty ? null : (_reference != null ? _apresPaiement : _confirmer)),
        ),
      ]),
    );
  }

  Widget _ligneRecap(AppPalette p, String a, String b, {bool fort = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(a, style: interStyle(fort ? p.c.title : p.mutedText, size: fort ? 16 : 15, w: fort ? FontWeight.w600 : FontWeight.w400)),
          const Spacer(),
          Text(b, style: interStyle(p.c.title, size: fort ? 17 : 15, w: fort ? FontWeight.w600 : FontWeight.w400)),
        ]),
      );
}
