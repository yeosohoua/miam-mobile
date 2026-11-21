import 'package:miam_assets/miam_assets.dart';
import 'package:flutter/material.dart';

import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_stores.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../login/presentation/widgets/blur_sheet.dart';
import '../../../shop/presentation/widgets/articles_widgets.dart' show QtyStepper;

/// Ouvre le panier en bottom sheet plein ecran (fond flou).
Future<void> showCartSheet(BuildContext context) {
  return showBlurSheet<void>(context, child: const CartContent());
}

/// Page autonome (route '/cart') : meme contenu.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppPalette(context).c;
    return Scaffold(backgroundColor: c.background, body: const CartContent());
  }
}

class CartContent extends StatefulWidget {
  const CartContent({super.key});
  @override
  State<CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  final _cart = CartStore.instance;
  @override
  void initState() {
    super.initState();
    _cart.addListener(_maj);
  }

  @override
  void dispose() {
    _cart.removeListener(_maj);
    super.dispose();
  }

  void _maj() {
    if (mounted) setState(() {});
  }

  void _valider() {
    final nav = Navigator.of(context);
    nav.pop();
    nav.pushNamed('/finalize-cart-order');
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final h = mq.size.height - 80.4;
    final bottom = mq.padding.bottom;
    final vide = _cart.lines.isEmpty;

    return SizedBox(
      height: h,
      child: Column(children: [
        SizedBox(
          height: 71.2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const SizedBox(width: 36),
              Expanded(child: Text('Panier', textAlign: TextAlign.center, style: interStyle(c.title, size: 13.4, w: FontWeight.w500, h: 1.2))),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(width: 36, height: 36, child: Icon(Icons.cancel_outlined, size: 20, color: p.dark ? Colors.white : const Color(0xFF8A8A8A))),
              ),
            ]),
          ),
        ),
        Expanded(
          child: vide
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(MiamAssets.emptyStates.addToBasket, package: 'miam_assets', width: 142, height: 142),
                  const SizedBox(height: 22),
                  Text('« Votre panier est vide »', textAlign: TextAlign.center, style: interStyle(c.subtitle, size: 16, h: 1.2, ls: -0.3)),
                ])
              : ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                  for (final l in _cart.lines)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.divider, width: 0.7))),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 14.4, w: FontWeight.w500)),
                            const SizedBox(height: 3),
                            Text(fcfa(l.prix * l.quantite), style: interStyle(p.mutedText, size: 13)),
                          ]),
                        ),
                        QtyStepper(value: l.quantite, min: 0, onChanged: (v) => _cart.setQty(l.cle, v)),
                      ]),
                    ),
                ]),
        ),
        if (!vide)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              Text('Total', style: interStyle(c.subtitle, size: 14)),
              const Spacer(),
              Text(fcfa(_cart.total), style: dmStyle(c.title, size: 18, w: FontWeight.w600, ls: -0.4)),
            ]),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 8),
          child: vide
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    height: 45.6,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all(color: c.outline), borderRadius: BorderRadius.circular(12)),
                    child: Text('Parcourir', style: interStyle(c.title, size: 14.1, w: FontWeight.w500, h: 1.2, ls: -0.4)),
                  ),
                )
              : LoadingButton(label: 'Commander', onTap: _valider),
        ),
      ]),
    );
  }
}
