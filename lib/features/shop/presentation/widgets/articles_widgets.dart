import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api/erp_api.dart';
import '../../../../core/api/erp_stores.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/net_image.dart';
import '../../../cart/presentation/screens/cart_screen.dart';

void ajouterArticle(BuildContext context, ArticleErp a, {int quantite = 1}) {
  HapticFeedback.selectionClick();
  CartStore.instance.add(CartLine(articleId: a.id, nom: a.nom, prix: a.prix, quantite: quantite));
  showAppToast(context, '${a.nom} ajouté au panier');
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 1});
  final int value, min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    Widget bouton(IconData i, VoidCallback? f) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: f,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: p.chipNeutral, borderRadius: BorderRadius.circular(10)),
            child: Icon(i, size: 18, color: f == null ? p.mutedText : c.title),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      bouton(Icons.remove, value > min ? () => onChanged(value - 1) : null),
      SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.center, style: interStyle(c.title, size: 16, w: FontWeight.w600))),
      bouton(AppIcons.plus, value < 20 ? () => onChanged(value + 1) : null),
    ]);
  }
}

/// Ligne d'article : image, nom, prix et bouton d'ajout rapide.
class ArticleRow extends StatelessWidget {
  const ArticleRow({super.key, required this.article, required this.onTap});
  final ArticleErp article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.divider, width: 0.7))),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 72, height: 72, child: NetImage(url: article.image, placeholder: p.tile))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 14.6, w: FontWeight.w500)),
              if (article.categorie != null) Text(article.categorie!, style: interStyle(p.mutedText, size: 12.2)),
              const SizedBox(height: 4),
              Text(fcfa(article.prix), style: dmStyle(c.title, size: 15, w: FontWeight.w600, ls: -0.3)),
            ]),
          ),
          GestureDetector(
            onTap: () => ajouterArticle(context, article),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(10)),
              child: Icon(AppIcons.plus, size: 18, color: c.onPrimary),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Carte compacte (accueil : meilleures offres).
class ArticleMiniCard extends StatelessWidget {
  const ArticleMiniCard({super.key, required this.article, required this.onTap});
  final ArticleErp article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette(context);
    final c = p.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: c.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(height: 100, width: double.infinity, child: NetImage(url: article.image, placeholder: p.tile))),
          const SizedBox(height: 8),
          Text(article.nom, maxLines: 2, overflow: TextOverflow.ellipsis, style: interStyle(c.title, size: 13.6, w: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(fcfa(article.prix), style: dmStyle(c.title, size: 14.6, w: FontWeight.w600, ls: -0.3)),
        ]),
      ),
    );
  }
}

/// Barre flottante "Voir le panier" (visible seulement si le panier n'est pas vide).
class CartBar extends StatelessWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppPalette(context).c;
    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (_, __) {
        final s = CartStore.instance;
        if (s.count == 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => showCartSheet(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(AppIcons.basketFilled, size: 20, color: c.onPrimary),
              const SizedBox(width: 10),
              Text('Voir le panier (${s.count})', style: interStyle(c.onPrimary, size: 14.2, w: FontWeight.w500)),
              const Spacer(),
              Text(fcfa(s.total), style: interStyle(c.onPrimary, size: 14.2, w: FontWeight.w600)),
            ]),
          ),
        );
      },
    );
  }
}
