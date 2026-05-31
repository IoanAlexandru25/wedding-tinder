import 'dart:convert';

import 'package:http/http.dart' as http;

class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
  });

  final String method;
  final Uri url;
  final Map<String, String> headers;

  // Raw JSON body string for POST/PATCH requests.
  final String? body;

  Map<String, dynamic>? get decodedBody =>
      body != null ? jsonDecode(body!) as Map<String, dynamic> : null;
}

/// Minimal fake HTTP client for unit-testing API services.
///
/// Stubs are keyed by 'METHOD /path' (e.g. 'GET /vendors').
/// All outgoing requests are recorded in [requests] for assertion.
class FakeHttpClient extends http.BaseClient {
  final List<RecordedRequest> requests = [];
  final Map<String, http.Response> _stubs = {};

  void stub(
    String method,
    String path, {
    required int status,
    required Object body,
  }) {
    final bodyStr = body is String ? body : jsonEncode(body);
    _stubs['$method $path'] = http.Response(
      bodyStr,
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  RecordedRequest get lastRequest => requests.last;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = request is http.Request ? request.body : null;
    // Normalize header keys to lowercase — HTTP headers are case-insensitive.
    final normalizedHeaders = {
      for (final e in request.headers.entries) e.key.toLowerCase(): e.value,
    };
    requests.add(RecordedRequest(
      method: request.method,
      url: request.url,
      headers: normalizedHeaders,
      body: body,
    ));

    final key = '${request.method} ${request.url.path}';
    final response = _stubs[key] ??
        http.Response(
          '{"code":"stub/missing","message":"No stub for $key"}',
          500,
          headers: {'content-type': 'application/json'},
        );

    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}
