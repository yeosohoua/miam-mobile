import 'package:flutter/material.dart';

import '../../../../core/api/erp_api.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/sub_page.dart';
import '../../../orders/presentation/screens/orders_screen.dart';

/// Détail d'une commande. Argument de route : [CommandeErp].
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final o = ModalRoute.of(context)?.settings.arguments;
    if (o is! CommandeErp) {
      return SubPage(title: 'Détail de la commande', child: Padding(padding: const EdgeInsets.all(24), child: Text('Commande introuvable.', style: interStyle(c.subtitle))));
    }

    Widget bloc(List<Widget> e) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: e),
        );
    Widget sep() => Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: p.divider));
    Widget titre(String t) => Text(t, style: interStyle(p.mutedText, size: 14.4));
    Widget choix(IconData i, String t) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: p.line)),
              child: Icon(i, size: 22, color: c.title),
            ),
            const SizedBox(width: 12),
            Text(t, style: interStyle(c.title, size: 15.4, w: FontWeight.w500)),
          ]),
        );
    Widget recap(String a, String b, {bool fort = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Text(a, style: interStyle(fort ? c.title : p.mutedText, size: fort ? 16 : 15, w: fort ? FontWeight.w600 : FontWeight.w400)),
            const Spacer(),
            Text(b, style: interStyle(c.title, size: fort ? 17 : 15, w: fort ? FontWeight.w600 : FontWeight.w400)),
          ]),
        );

    return SubPage(
      title: 'Détail de la commande',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(children: [
          bloc([
            Row(children: [
              EtabLogo(url: o.etabLogo, size: 48),
              const SizedBox(width: 12),
              Expanded(child: Text(o.etabNom, maxLines: 1, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 15.4, w: FontWeight.w500))),
              Text('(${o.articles} article${o.articles > 1 ? 's' : ''})', style: interStyle(p.mutedText, size: 14)),
            ]),
            const SizedBox(height: 14),
            for (final l in o.lignes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text('${l.nom} ×${l.quantite}', style: interStyle(c.title, size: 14.6, w: FontWeight.w500))),
                  Text(fcfa(l.prix * l.quantite), style: dmStyle(c.title, size: 15.6, w: FontWeight.w600, ls: -0.3)),
                ]),
              ),
          ]),
          bloc([
            Row(children: [
              Text('Date et heure :', style: interStyle(p.mutedText, size: 14.6)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: p.chipNeutral, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(AppIcons.clock, size: 16, color: p.mutedText),
                  const SizedBox(width: 6),
                  Text(dateHeure(o.date), style: interStyle(p.mutedText, size: 13)),
                ]),
              ),
            ]),
            sep(),
            Row(children: [
              Text('Statut :', style: interStyle(p.mutedText, size: 14.6)),
              const Spacer(),
              StatutPastille(commande: o),
            ]),
            sep(),
            titre('Mode :'),
            choix(o.mode == 'SUR_PLACE' ? Icons.restaurant_outlined : AppIcons.bag, o.modeLibelle),
            sep(),
            titre('Moyen de paiement :'),
            choix(o.paiement == 'SOLDE' ? AppIcons.wallet : Icons.payments_outlined, o.paiementLibelle),
          ]),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: p.tile, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Récapitulatif', style: interStyle(c.title, size: 16, w: FontWeight.w500)),
              const SizedBox(height: 10),
              recap('Sous-total', fcfa(o.total)),
              const SizedBox(height: 6),
              recap('Total', fcfa(o.total), fort: true),
            ]),
          ),
        ]),
      ),
    );
  }
}
