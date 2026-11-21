import 'api_client.dart';

/// Montant en FCFA : 5000 -> "5.000F".
String fcfa(num n) {
  final v = n.round();
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}${b}F';
}

String? erpUrl(Object? chemin) => chemin is String && chemin.isNotEmpty ? ApiClient.instance.imageUrl(chemin) : null;

const _mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
const _jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];

/// "2026-11-21" -> "samedi 21 nov."
String dateLongue(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]}';
}

String dateHeure(DateTime d) {
  final l = d.toLocal();
  final h = l.hour.toString().padLeft(2, '0');
  final m = l.minute.toString().padLeft(2, '0');
  return '${l.day} ${_mois[l.month - 1]} ${l.year} · $h:$m';
}

String majuscule(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class Compte {
  Compte(Map<String, dynamic> j)
      : inscritId = j['inscritId'] as String? ?? '',
        nom = j['nom'] as String? ?? '',
        matricule = j['matricule'] as String? ?? '',
        qr = j['qr'] as String? ?? '',
        solde = (j['solde'] as num?)?.toInt() ?? 0,
        etablissement = j['etablissement'] as String? ?? '',
        prepaye = j['prepaye'] == true;
  final String inscritId, nom, matricule, qr, etablissement;
  final int solde;
  final bool prepaye;
}

class WalletData {
  WalletData(Map<String, dynamic> j)
      : role = j['role'] as String? ?? '',
        nom = j['nom'] as String? ?? '',
        rechargeActive = j['rechargeActive'] == true,
        min = (j['min'] as num?)?.toInt() ?? 500,
        max = (j['max'] as num?)?.toInt() ?? 500000,
        qr = j['qr'] as String? ?? '',
        comptes = ((j['comptes'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(Compte.new).toList();
  final String role, nom, qr;
  final bool rechargeActive;
  final int min, max;
  final List<Compte> comptes;
}

class TransactionErp {
  TransactionErp(Map<String, dynamic> j)
      : libelle = j['libelle'] as String? ?? '',
        montant = (j['montant'] as num?)?.toInt() ?? 0,
        date = DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now();
  final String libelle;
  final int montant;
  final DateTime date;
}

class CategorieErp {
  CategorieErp(Map<String, dynamic> j)
      : nom = j['nom'] as String? ?? '',
        articles = (j['articles'] as num?)?.toInt() ?? 0,
        image = erpUrl(j['image']);
  final String nom;
  final int articles;
  final String? image;
}

class ArticleErp {
  ArticleErp(Map<String, dynamic> j)
      : id = j['id'] as String? ?? '',
        nom = j['nom'] as String? ?? '',
        prix = (j['prix'] as num?)?.toInt() ?? 0,
        categorie = j['categorie'] as String?,
        image = erpUrl(j['image']);
  final String id, nom;
  final int prix;
  final String? categorie;
  final String? image;
}

class PlatErp {
  PlatErp(Map<String, dynamic> j)
      : nom = j['nom'] as String? ?? '',
        description = j['description'] as String?,
        image = erpUrl(j['image']);
  final String nom;
  final String? description, image;
}

class MenuRepas {
  MenuRepas(Map<String, dynamic> j)
      : date = j['date'] as String? ?? '',
        service = j['service'] as String? ?? '',
        libelle = j['libelle'] as String? ?? '',
        prix = (j['prix'] as num?)?.toInt(),
        image = erpUrl(j['image']),
        plats = ((j['plats'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(PlatErp.new).toList();
  final String date, service, libelle;
  final int? prix;
  final String? image;
  final List<PlatErp> plats;
  String get cle => '$date|$service';
}

class MenusReponse {
  MenusReponse(Map<String, dynamic> j)
      : mode = j['mode'] as String? ?? 'PANIER',
        menus = ((j['menus'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(MenuRepas.new).toList();
  final String mode;
  final List<MenuRepas> menus;
  bool get reserver => mode == 'RESERVER';
}

class JourSemaine {
  JourSemaine(Map<String, dynamic> j)
      : jour = j['jour'] as String? ?? '',
        date = j['date'] as String? ?? '',
        image = erpUrl(j['image']),
        libelles = ((j['menus'] as List?) ?? const []).whereType<Map<String, dynamic>>().map((m) => m['libelle'] as String? ?? '').toList(),
        plats = ((j['menus'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .expand((m) => ((m['plats'] as List?) ?? const []).whereType<String>())
            .toList();
  final String jour, date;
  final String? image;
  final List<String> libelles, plats;
}

class LigneCmd {
  LigneCmd(Map<String, dynamic> j)
      : nom = j['nom'] as String? ?? '',
        prix = (j['prix'] as num?)?.toInt() ?? 0,
        quantite = (j['quantite'] as num?)?.toInt() ?? 1;
  final String nom;
  final int prix, quantite;
}

class CommandeErp {
  CommandeErp(Map<String, dynamic> j)
      : id = j['id'] as String? ?? '',
        total = (j['total'] as num?)?.toInt() ?? 0,
        statut = j['statut'] as String? ?? 'EN_ATTENTE',
        paiement = j['paiement'] as String? ?? 'ESPECES',
        mode = j['mode'] as String? ?? 'A_EMPORTER',
        etabNom = (j['etablissement'] is Map ? (j['etablissement'] as Map)['nom'] as String? : null) ?? '',
        etabLogo = j['etablissement'] is Map ? erpUrl((j['etablissement'] as Map)['logo']) : null,
        date = DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        lignes = ((j['lignes'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(LigneCmd.new).toList();
  final String id, statut, paiement, mode, etabNom;
  final String? etabLogo;
  final int total;
  final DateTime date;
  final List<LigneCmd> lignes;

  int get articles => lignes.fold(0, (s, l) => s + l.quantite);
  String get statutLibelle => switch (statut) {
        'EN_ATTENTE' => 'En attente',
        'PRETE' => 'Prête',
        'SERVIE' => 'Servie',
        'ANNULEE' => 'Annulée',
        _ => statut,
      };
  String get modeLibelle => mode == 'SUR_PLACE' ? 'Manger sur place' : 'À emporter';
  String get paiementLibelle => paiement == 'SOLDE' ? 'Portefeuille' : 'Espèces';
}

class Recharge {
  const Recharge(this.url, this.reference);
  final String url, reference;
}

class ErpApi {
  const ErpApi._();
  static ApiClient get _c => ApiClient.instance;

  static Future<WalletData> wallet() async => WalletData(await _c.get('/wallet'));

  static Future<List<TransactionErp>> transactions(String? inscritId) async {
    final r = await _c.get('/wallet/transactions', query: {if (inscritId != null && inscritId.isNotEmpty) 'inscritId': inscritId});
    return ((r['transactions'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(TransactionErp.new).toList();
  }

  static Future<Recharge> recharge(String inscritId, int montant) async {
    final r = await _c.post('/wallet/recharge', body: {'inscritId': inscritId, 'montant': montant});
    return Recharge(r['url'] as String? ?? '', r['reference'] as String? ?? '');
  }

  /// Renvoie le message a afficher et si le solde a ete credite.
  static Future<({String message, bool credite, bool enAttente})> verifier(String reference) async {
    final r = await _c.post('/wallet/verifier', body: {'reference': reference});
    return (message: r['message'] as String? ?? '', credite: r['credite'] == true, enAttente: r['enAttente'] == true);
  }

  static Future<String> carteCadeau(String inscritId, String code) async {
    final r = await _c.post('/wallet/carte-cadeau', body: {'inscritId': inscritId, 'code': code});
    return (r['message'] as String?) ?? 'Carte cadeau validée.';
  }

  static Future<List<CategorieErp>> categories() async {
    final r = await _c.get('/categories');
    return ((r['categories'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(CategorieErp.new).toList();
  }

  static Future<List<ArticleErp>> articles({String? categorie}) async {
    final r = await _c.get('/articles', query: {if (categorie != null && categorie.isNotEmpty) 'categorie': categorie});
    return ((r['articles'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(ArticleErp.new).toList();
  }

  static Future<List<JourSemaine>> semaine() async {
    final r = await _c.get('/menus/semaine');
    return ((r['jours'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(JourSemaine.new).toList();
  }

  static Future<MenusReponse> menus(String du, String au, {String? inscritId}) async =>
      MenusReponse(await _c.get('/menus', query: {'du': du, 'au': au, if (inscritId != null && inscritId.isNotEmpty) 'inscritId': inscritId}));

  /// Reservations du compte : cles "date|service" des repas deja reserves.
  static Future<Set<String>> reservations(String du, String au, {String? inscritId}) async {
    final r = await _c.get('/reservations', query: {'du': du, 'au': au, if (inscritId != null && inscritId.isNotEmpty) 'inscritId': inscritId});
    return ((r['reservations'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((x) => x['statut'] == 'BOOKED')
        .map((x) => '${x['date']}|${x['service']}')
        .toSet();
  }

  static Future<void> reserver(String date, String service, {String? inscritId}) async {
    await _c.post('/reservations', body: {'date': date, 'service': service, if (inscritId != null && inscritId.isNotEmpty) 'inscritId': inscritId});
  }

  static Future<Map<String, dynamic>> commander(List<Map<String, dynamic>> lignes, {String? inscritId, required String mode, required String paiement}) =>
      _c.post('/commandes', body: {'lignes': lignes, 'mode': mode, 'paiement': paiement, if (inscritId != null && inscritId.isNotEmpty) 'inscritId': inscritId});

  static Future<List<CommandeErp>> commandes() async {
    final r = await _c.get('/commandes');
    return ((r['commandes'] as List?) ?? const []).whereType<Map<String, dynamic>>().map(CommandeErp.new).toList();
  }

  static Future<String?> photo() async {
    final r = await _c.get('/me');
    return erpUrl(r['photo']);
  }
}
