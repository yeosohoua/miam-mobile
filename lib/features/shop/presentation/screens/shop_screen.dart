import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_stores.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/net_image.dart';
import '../widgets/articles_widgets.dart';

/// Detail d'un menu du jour. Argument de route : {'date': 'AAAA-MM-JJ', 'service': optionnel}.
/// Abonnes (parent, eleve) : reservation ; autres comptes : ajout au panier.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _date = '';
  MenusReponse? _rep;
  Set<String> _reserves = {};
  String? _service;
  String? _err;
  bool _busy = false;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) {
      _date = '${arg['date'] ?? ''}';
      _service = arg['service'] as String?;
    }
    _charger();
  }

  Future<void> _charger() async {
    if (_date.isEmpty) {
      setState(() => _err = 'Menu introuvable.');
      return;
    }
    try {
      final id = WalletStore.instance.inscritId;
      final rep = await ErpApi.menus(_date, _date, inscritId: id);
      var res = <String>{};
      if (rep.reserver) {
        try {
          res = await ErpApi.reservations(_date, _date, inscritId: id);
        } on ApiException {
          // Etat de reservation indisponible : le serveur refusera un doublon.
        }
      }
      if (!mounted) return;
      setState(() {
        _rep = rep;
        _reserves = res;
        if (rep.menus.isNotEmpty && !rep.menus.any((m) => m.service == _service)) _service = rep.menus.first.service;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  MenuRepas? get _menu {
    final r = _rep;
    if (r == null) return null;
    for (final m in r.menus) {
      if (m.service == _service) return m;
    }
    return null;
  }

  Future<void> _action(MenuRepas m) async {
    HapticFeedback.selectionClick();
    final r = _rep!;
    if (r.reserver) {
      setState(() => _busy = true);
      try {
        await ErpApi.reserver(m.date, m.service, inscritId: WalletStore.instance.inscritId);
        if (!mounted) return;
        setState(() => _reserves = {..._reserves, m.cle});
        showAppToast(context, 'Repas réservé pour ${dateLongue(m.date)}.');
      } on ApiException catch (e) {
        if (mounted) showAppToast(context, e.message);
      }
      if (mounted) setState(() => _busy = false);
    } else {
      CartStore.instance.add(CartLine(date: m.date, service: m.service, nom: '${m.libelle} · ${dateLongue(m.date)}', prix: m.prix ?? 0));
      showAppToast(context, '${m.libelle} ajouté au panier');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final r = _rep;
    final m = _menu;
    final image = m?.image ?? r?.menus.map((x) => x.image).firstWhere((i) => i != null, orElse: () => null) ?? (m != null && m.plats.isNotEmpty ? m.plats.first.image : null);

    Widget corps;
    if (_err != null) {
      corps = Padding(padding: const EdgeInsets.all(24), child: Text(_err!, style: interStyle(c.error, size: 14)));
    } else if (r == null) {
      corps = const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    } else if (r.menus.isEmpty) {
      corps = Padding(padding: const EdgeInsets.all(24), child: Text("Aucun menu publié pour ce jour.", style: interStyle(c.subtitle, size: 15)));
    } else {
      corps = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 36,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            for (final x in r.menus)
              GestureDetector(
                onTap: () => setState(() => _service = x.service),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: x.service == _service ? c.primary : p.chipNeutral, borderRadius: BorderRadius.circular(10)),
                  child: Text(x.libelle, style: interStyle(x.service == _service ? c.onPrimary : c.title, size: 13.4, w: FontWeight.w500)),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        if (m != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Icon(AppIcons.clock, size: 18, color: p.mutedText),
              const SizedBox(width: 6),
              Text(m.prix == null ? 'Tarif non défini' : fcfa(m.prix!), style: interStyle(c.title, size: 14, w: FontWeight.w600)),
              const SizedBox(width: 12),
              Text('${m.plats.length} plat${m.plats.length > 1 ? 's' : ''}', style: interStyle(p.mutedText, size: 13)),
            ]),
          ),
          const SizedBox(height: 14),
          for (final pl in m.plats)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 64, height: 64, child: NetImage(url: pl.image, placeholder: p.chipNeutral))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pl.nom, style: interStyle(c.title, size: 14.6, w: FontWeight.w500)),
                      if ((pl.description ?? '').isNotEmpty) Text(pl.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: interStyle(p.mutedText, size: 12.4)),
                    ]),
                  ),
                ]),
              ),
            ),
        ],
      ]);
    }

    final dejaReserve = m != null && _reserves.contains(m.cle);
    String label = '';
    VoidCallback? tap;
    if (m != null && r != null) {
      if (r.reserver) {
        label = dejaReserve ? 'Déjà réservé' : (m.prix == null ? 'Réserver' : 'Réserver · ${fcfa(m.prix!)}');
        tap = dejaReserve || _busy ? null : () => _action(m);
      } else {
        label = m.prix == null ? 'Tarif indisponible' : 'Ajouter au panier · ${fcfa(m.prix!)}';
        tap = m.prix == null ? null : () => _action(m);
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(children: [
          ListView(padding: EdgeInsets.zero, children: [
            SizedBox(height: 230, child: NetImage(url: image, placeholder: p.tile)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(majuscule(dateLongue(_date)), style: dmStyle(c.title, size: 22, w: FontWeight.w600, ls: -0.6)),
            ),
            corps,
            SizedBox(height: 150 + mq.padding.bottom),
          ]),
          Positioned(
            top: mq.padding.top + 10,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: c.background, shape: BoxShape.circle),
                child: Icon(AppIcons.arrowLeft, size: 22, color: c.title),
              ),
            ),
          ),
          if (m != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12 + mq.padding.bottom,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (r != null && !r.reserver) ...[const CartBar(), const SizedBox(height: 8)],
                LoadingButton(label: label, loading: _busy, onTap: tap),
              ]),
            ),
        ]),
      ),
    );
  }
}
