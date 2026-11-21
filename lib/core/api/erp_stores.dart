import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'erp_api.dart';

/// Portefeuille charge depuis l'ERP (partage entre l'accueil et l'ecran Portefeuille).
class WalletStore extends ChangeNotifier {
  WalletStore._();
  static final WalletStore instance = WalletStore._();

  WalletData? data;
  bool loading = false;
  String? error;
  int index = 0;

  Compte? get compte => data != null && data!.comptes.isNotEmpty ? data!.comptes[index.clamp(0, data!.comptes.length - 1)] : null;
  String? get inscritId => compte?.inscritId;
  int? get solde => compte?.solde;
  String get qr => compte?.qr ?? data?.qr ?? '';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await ErpApi.wallet();
      if (index >= (data!.comptes.length)) index = 0;
    } on ApiException catch (e) {
      error = e.message;
    }
    loading = false;
    notifyListeners();
  }

  void select(int i) {
    index = i;
    notifyListeners();
  }
}

class CartLine {
  CartLine({this.articleId, this.date, this.service, required this.nom, required this.prix, this.quantite = 1});
  final String? articleId, date, service;
  final String nom;
  final int prix;
  int quantite;
  String get cle => articleId ?? '$date|$service';
  Map<String, dynamic> toJson() => articleId != null ? {'articleId': articleId, 'quantite': quantite} : {'date': date, 'service': service, 'quantite': quantite};
}

/// Panier local (articles et repas), valide aupres de l'ERP.
class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  final List<CartLine> lines = [];
  int get count => lines.fold(0, (s, l) => s + l.quantite);
  int get total => lines.fold(0, (s, l) => s + l.prix * l.quantite);
  int qty(String cle) => lines.where((l) => l.cle == cle).fold(0, (s, l) => s + l.quantite);

  void add(CartLine l) {
    final ex = lines.where((x) => x.cle == l.cle);
    if (ex.isNotEmpty) {
      ex.first.quantite = (ex.first.quantite + l.quantite).clamp(1, 20);
    } else {
      lines.add(l);
    }
    notifyListeners();
  }

  void setQty(String cle, int q) {
    final i = lines.indexWhere((l) => l.cle == cle);
    if (i < 0) return;
    if (q <= 0) {
      lines.removeAt(i);
    } else {
      lines[i].quantite = q.clamp(1, 20);
    }
    notifyListeners();
  }

  void clear() {
    lines.clear();
    notifyListeners();
  }

  /// Envoie la commande. Leve [ApiException] avec un message lisible.
  Future<Map<String, dynamic>> valider({String? inscritId, required String mode, required String paiement}) async {
    final r = await ErpApi.commander(lines.map((l) => l.toJson()).toList(), inscritId: inscritId, mode: mode, paiement: paiement);
    clear();
    return r;
  }
}
