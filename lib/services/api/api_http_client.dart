import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../service_exception.dart';

class ApiHttpClient {
  ApiHttpClient(this._inner, this._getToken);

  final http.Client _inner;
  final Future<String?> Function() _getToken;

  Future<List<dynamic>> getList(String path) async {
    final response = await _inner.get(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
    );
    _checkStatus(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _inner.get(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
    );
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _inner.post(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final response = await _inner.patch(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> postNoContent(String path, Map<String, dynamic> body) async {
    final response = await _inner.post(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _checkStatus(response);
  }

  Future<void> delete(String path) async {
    final response = await _inner.delete(
      Uri.parse('$kBaseUrl$path'),
      headers: await _headers(),
    );
    _checkStatus(response);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final bodyStr = response.body.isEmpty ? '{}' : response.body;
    final Map<String, dynamic> error;
    try {
      error = jsonDecode(bodyStr) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('api/unknown', 'HTTP ${response.statusCode}');
    }
    final code = error['code'] as String? ?? 'api/unknown';
    final message = error['message'] as String? ?? 'An unexpected error occurred.';
    throw _mapError(code, message, response.statusCode);
  }

  static ServiceException _mapError(String code, String message, int status) {
    if (status == 401) return const ApiException('unauthorized', 'Authentication required.');
    if (status == 403) return const ApiException('forbidden', 'Access denied.');
    final slash = code.indexOf('/');
    final prefix = slash >= 0 ? code.substring(0, slash) : code;
    final suffix = slash >= 0 ? code.substring(slash + 1) : code;
    switch (prefix) {
      case 'wedding':
        return WeddingException(suffix, message);
      case 'user':
        return UserException(suffix, message);
      case 'selection':
        return SelectionException(suffix, message);
      default:
        return ApiException(code, message);
    }
  }
}
