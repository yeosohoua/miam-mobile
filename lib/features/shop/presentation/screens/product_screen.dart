import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/erp_api.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/net_image.dart';
import '../widgets/articles_widgets.dart';

/// Fiche article. Argument de route : [ArticleErp].
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _qte = 1;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    final mq = MediaQuery.of(context);
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is! ArticleErp) {
      return Scaffold(backgroundColor: c.background, body: Center(child: Text('Article introuvable.', style: interStyle(c.subtitle))));
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(children: [
          ListView(padding: EdgeInsets.zero, children: [
            SizedBox(height: 340 + mq.padding.top * 0, child: NetImage(url: a.image, placeholder: p.tile)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (a.categorie != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: p.chipNeutral, borderRadius: BorderRadius.circular(8)),
                    child: Text(a.categorie!, style: interStyle(c.title, size: 12.2, w: FontWeight.w500)),
                  ),
                const SizedBox(height: 10),
                Text(a.nom, style: dmStyle(c.title, size: 22, w: FontWeight.w600, ls: -0.6)),
                const SizedBox(height: 6),
                Text(fcfa(a.prix), style: dmStyle(c.title, size: 20, w: FontWeight.w600, ls: -0.5)),
                const SizedBox(height: 22),
                Row(children: [
                  Text('Quantité', style: interStyle(c.subtitle, size: 14)),
                  const Spacer(),
                  QtyStepper(value: _qte, onChanged: (v) => setState(() => _qte = v)),
                ]),
              ]),
            ),
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 12 + mq.padding.bottom,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CartBar(),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  ajouterArticle(context, a, quantite: _qte);
                  Navigator.of(context).maybePop();
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text('Ajouter au panier · ${fcfa(a.prix * _qte)}', style: interStyle(c.onPrimary, size: 14.4, w: FontWeight.w500)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
