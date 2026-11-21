import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

/// Client de l'API mobile de l'ERP Miam (/api/mobile/v1). Le jeton est envoye a chaque appel.
/// Adresse : --dart-define=API_URL=https://... ; par defaut http://localhost:3001 (avec `adb reverse tcp:3001 tcp:3001`).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static String get baseUrl => Env.apiUrl.isNotEmpty ? Env.apiUrl : 'http://localhost:3001';

  String? token;

  /// Appelee quand le serveur refuse le jeton (session expiree ou revoquee).
  VoidCallback? onUnauthorized;

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl/api/mobile/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
    validateStatus: (_) => true,
  ));

  /// En-tetes a joindre aux images protegees (cached_network_image : httpHeaders).
  Map<String, String> get imageHeaders => token == null ? const {} : {'Authorization': 'Bearer $token'};

  /// Adresse complete d'une image renvoyee par l'API (chemin relatif).
  String imageUrl(String chemin) => chemin.startsWith('http') ? chemin : '$baseUrl$chemin';

  Future<Map<String, dynamic>> get(String chemin, {Map<String, dynamic>? query}) => _envoyer('GET', chemin, query: query);
  Future<Map<String, dynamic>> post(String chemin, {Object? body}) => _envoyer('POST', chemin, body: body);

  Future<Map<String, dynamic>> _envoyer(String methode, String chemin, {Map<String, dynamic>? query, Object? body}) async {
    try {
      final r = await _dio.request<dynamic>(
        chemin,
        data: body,
        queryParameters: query,
        options: Options(method: methode, headers: token == null ? null : {'Authorization': 'Bearer $token'}),
      );
      final data = r.data;
      final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
      final status = r.statusCode ?? 0;
      if (status >= 200 && status < 300) return map;
      if (status == 401 && token != null) onUnauthorized?.call();
      throw ApiException((map['error'] as String?) ?? 'Une erreur est survenue. Réessayez.', status: status);
    } on DioException catch (e) {
      throw ApiException(_messageReseau(e));
    }
  }

  String _messageReseau(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Le serveur met trop de temps à répondre. Réessayez.';
      case DioExceptionType.connectionError:
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}