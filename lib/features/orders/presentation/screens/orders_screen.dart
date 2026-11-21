import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_session.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/net_image.dart';

const double _kHeaderH = 50.6;
const double _kTitleBase = 28.35;

/// Pastille de statut (ambre = en attente, bleu = prête/servie, rouge = annulée).
class StatutPastille extends StatelessWidget {
  const StatutPastille({super.key, required this.commande});
  final CommandeErp commande;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    Color fg, bg;
    switch (commande.statut) {
      case 'PRETE':
      case 'SERVIE':
        fg = p.infoText;
        bg = p.infoBg;
      case 'ANNULEE':
        fg = p.coral;
        bg = p.chipNeutral;
      default:
        fg = p.pendingText;
        bg = p.pendingBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(commande.statutLibelle, style: interStyle(fg, size: 12, w: FontWeight.w500, h: 1.2, ls: -0.24)),
    );
  }
}

class EtabLogo extends StatelessWidget {
  const EtabLogo({super.key, required this.url, this.size = 44});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.line)),
      child: ClipOval(child: NetImage(url: url, placeholder: p.tile)),
    );
  }
}

/// Onglet Commandes : commandes réelles de la personne connectée.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<CommandeErp>? _liste;
  String? _err;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    if (!ErpSession.instance.isSignedIn) {
      setState(() => _liste = const []);
      return;
    }
    try {
      final l = await ErpApi.commandes();
      if (mounted) {
        setState(() {
          _liste = l;
          _err = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final inset = mq.padding.top;
    final navH = 78.8 + mq.padding.bottom;
    final l = _liste;

    Widget corps;
    if (_err != null && l == null) {
      corps = Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_err!, textAlign: TextAlign.center, style: interStyle(c.error, size: 14))));
    } else if (l == null) {
      corps = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (l.isEmpty) {
      corps = ListView(children: [
        SizedBox(height: 160),
        Center(child: Text('Aucune commande pour le moment.', style: interStyle(c.subtitle, size: 15))),
      ]);
    } else {
      corps = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, navH + 16.9),
        itemCount: l.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _Carte(commande: l[i]),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: p.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: p.dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: c.background,
        body: Column(children: [
          Container(
            color: c.background,
            height: inset + _kHeaderH,
            child: Stack(children: [
              Positioned(left: 15.5, top: inset + _kTitleBase - DmBase.dm(17.4).ascentBox, child: Text('Commandes', style: dmStyle(c.title, size: 17.4, h: 1, ls: -0.52))),
              if (l != null && l.isNotEmpty)
                Positioned(
                  left: 128,
                  top: inset + 12.35,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.countBg, shape: BoxShape.circle),
                    child: Text('${l.length}', style: interStyle(p.mutedText, size: 10, w: FontWeight.w500, h: 1.2, ls: 0)),
                  ),
                ),
            ]),
          ),
          Expanded(child: RefreshIndicator(onRefresh: _charger, child: corps)),
        ]),
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.commande});
  final CommandeErp commande;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final o = commande;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pushNamed('/order-detail', arguments: o),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            EtabLogo(url: o.etabLogo),
            const SizedBox(width: 12),
            Expanded(child: Text(o.etabNom, maxLines: 1, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 15, w: FontWeight.w500))),
            StatutPastille(commande: o),
          ]),
          const SizedBox(height: 12),
          Text(o.lignes.map((l) => '${l.nom} ×${l.quantite}').join(', '), maxLines: 2, overflow: TextOverflow.ellipsis, style: interStyle(p.mutedText, size: 13.2)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(dateHeure(o.date), style: interStyle(p.mutedText, size: 12.6))),
            Text(fcfa(o.total), style: dmStyle(c.title, size: 16, w: FontWeight.w600, ls: -0.3)),
          ]),
        ]),
      ),
    );
  }
}
