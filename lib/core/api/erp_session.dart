import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';

/// Resultat d'une verification de code : la session n'est enregistree qu'apres confirmation ([ErpSession.adopt]).
class ErpLogin {
  const ErpLogin({required this.token, required this.name, required this.role, required this.etabName, required this.etabCode, this.etabLogo});
  final String token;
  final String name;

  /// PARENT, ELEVE ou EMPLOYE.
  final String role;
  final String etabName;
  final String etabCode;

  /// Adresse complete du logo de l'etablissement (null s'il n'en a pas).
  final String? etabLogo;

  String get description {
    final qui = switch (role) {
      'PARENT' => 'Parent',
      'ELEVE' => 'Élève',
      'EMPLOYE' => 'Employé',
      _ => '',
    };
    return qui.isEmpty ? name : '$qui · $name';
  }
}

/// Session de l'utilisateur connecte a l'ERP (parent, eleve ou employe). Le jeton est garde dans le stockage securise.
class ErpSession extends ChangeNotifier {
  ErpSession._();
  static final ErpSession instance = ErpSession._();

  static const _cleJeton = 'miam_jeton';
  static const _cleNom = 'miam_nom';
  static const _cleRole = 'miam_role';
  static const _cleEtab = 'miam_etab_nom';
  final _stockage = const FlutterSecureStorage();

  String? _jeton;
  String _nom = '';
  String _role = '';
  String _etabNom = '';

  bool get isSignedIn => _jeton != null;
  String get name => _nom;
  String get role => _role;
  String get etablissement => _etabNom;

  Future<void> load() async {
    ApiClient.instance.onUnauthorized = () {
      logout();
    };
    try {
      _jeton = await _stockage.read(key: _cleJeton);
      _nom = await _stockage.read(key: _cleNom) ?? '';
      _role = await _stockage.read(key: _cleRole) ?? '';
      _etabNom = await _stockage.read(key: _cleEtab) ?? '';
    } catch (_) {
      _jeton = null;
    }
    ApiClient.instance.token = _jeton;
  }

  /// Verifie le code d'acces aupres de l'ERP (l'etablissement se deduit du code) sans enregistrer la session.
  /// Leve une [ApiException] avec un message lisible en cas d'echec.
  Future<ErpLogin> authenticate(String code, {String etablissement = ''}) async {
    final r = await ApiClient.instance.post('/auth/code', body: {
      'code': code.trim(),
      if (etablissement.trim().isNotEmpty) 'etab': etablissement.trim(),
    });
    final jeton = r['token'];
    if (jeton is! String || jeton.isEmpty) throw const ApiException('Réponse inattendue du serveur.');
    final etab = r['etablissement'];
    return ErpLogin(
      token: jeton,
      name: (r['name'] as String?) ?? '',
      role: (r['role'] as String?) ?? '',
      etabName: etab is Map ? (etab['name'] as String? ?? '') : '',
      etabCode: etab is Map ? (etab['code'] as String? ?? '') : '',
      etabLogo: etab is Map && etab['logo'] is String ? ApiClient.instance.imageUrl(etab['logo'] as String) : null,
    );
  }

  /// Enregistre la session apres la confirmation de l'utilisateur.
  Future<void> adopt(ErpLogin l) async {
    _jeton = l.token;
    _nom = l.name;
    _role = l.role;
    _etabNom = l.etabName;
    ApiClient.instance.token = l.token;
    try {
      await _stockage.write(key: _cleJeton, value: l.token);
      await _stockage.write(key: _cleNom, value: l.name);
      await _stockage.write(key: _cleRole, value: l.role);
      await _stockage.write(key: _cleEtab, value: l.etabName);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> logout() async {
    _jeton = null;
    _nom = '';
    _role = '';
    _etabNom = '';
    ApiClient.instance.token = null;
    try {
      await _stockage.delete(key: _cleJeton);
      await _stockage.delete(key: _cleNom);
      await _stockage.delete(key: _cleRole);
      await _stockage.delete(key: _cleEtab);
    } catch (_) {}
    notifyListeners();
  }
}