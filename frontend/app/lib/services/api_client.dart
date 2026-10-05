import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Cliente HTTP centralizado: añade la URL base, cabeceras JSON y el token
/// JWT (si existe), y traduce las respuestas de error del backend en
/// [ApiException] con el mensaje `detail` que devuelve FastAPI.
class ApiClient {
  ApiClient({this.token}) : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  String? token;
  Future<void>? _refreshFuture;

  Future<void> saveSession({required String accessToken, required String refreshToken}) async {
    token = accessToken;
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<void> clearSession() async {
    token = null;
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<String?> readAccessToken() async => _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> readRefreshToken() async => _storage.read(key: AppConstants.refreshTokenKey);

  Future<bool> refreshSession() async {
    if (_refreshFuture != null) {
      await _refreshFuture!;
      return token != null;
    }

    final refreshToken = await readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearSession();
      return false;
    }

    _refreshFuture = _doRefresh(refreshToken);
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _doRefresh(String refreshToken) async {
    try {
      final response = await http.post(
        _uri('/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final newRefreshToken = (data['refresh_token'] as String?) ?? refreshToken;
        if (accessToken == null || accessToken.isEmpty) {
          await clearSession();
          return false;
        }
        await saveSession(accessToken: accessToken, refreshToken: newRefreshToken);
        return true;
      }
      await clearSession();
      return false;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(AppConstants.apiBaseUrl);
    return base.replace(
      path: '${base.path}$path',
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  dynamic _procesar(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) return null;
      return jsonDecode(utf8.decode(resp.bodyBytes));
    }
    String mensaje = 'Ha ocurrido un error (${resp.statusCode}).';
    try {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      if (data is Map && data['detail'] != null) {
        final detail = data['detail'];
        if (detail is String) {
          mensaje = detail;
        } else if (detail is List) {
          mensaje = detail.map((e) => e['msg'] ?? e.toString()).join('\n');
        }
      }
    } catch (_) {
      // Si el cuerpo no es JSON válido, se mantiene el mensaje genérico.
    }
    throw ApiException(resp.statusCode, mensaje);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final resp = await http.get(_uri(path, query), headers: _headers);
    return _handleResponse(resp, path);
  }

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    final resp = await http.post(
      _uri(path, query),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(resp, path);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final resp = await http.patch(_uri(path), headers: _headers, body: body != null ? jsonEncode(body) : null);
    return _handleResponse(resp, path);
  }

  Future<dynamic> delete(String path) async {
    final resp = await http.delete(_uri(path), headers: _headers);
    return _handleResponse(resp, path);
  }

  Future<dynamic> _handleResponse(http.Response resp, String path) async {
    if (resp.statusCode == 401 && !path.startsWith('/auth/login') && !path.startsWith('/auth/refresh') && !path.startsWith('/auth/logout')) {
      final refreshed = await refreshSession();
      if (refreshed) {
        final retryResp = await http.request(
          _uri(path).toString(),
          method: resp.request?.method ?? 'GET',
          headers: _headers,
          body: resp.request?.body,
        );
        return _procesar(retryResp);
      }
      throw ApiException(401, 'La sesión ha expirado.');
    }
    return _procesar(resp);
  }
}
