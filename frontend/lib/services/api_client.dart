import 'dart:convert';
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
  ApiClient({this.token});

  String? token;

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
    return _procesar(resp);
  }

  Future<dynamic> post(String path, {Object? body, Map<String, dynamic>? query}) async {
    final resp = await http.post(
      _uri(path, query),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _procesar(resp);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final resp = await http.patch(_uri(path), headers: _headers, body: body != null ? jsonEncode(body) : null);
    return _procesar(resp);
  }

  Future<dynamic> delete(String path) async {
    final resp = await http.delete(_uri(path), headers: _headers);
    return _procesar(resp);
  }
}
