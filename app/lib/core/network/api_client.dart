import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum ApiErrorKind {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  rateLimited,
  server,
}

class ApiException implements Exception {
  const ApiException(this.kind, this.message, {this.statusCode, this.details});

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;

  /// Structured `detail` from the server when it is an object (e.g. duplicate candidates).
  final Map<String, dynamic>? details;

  @override
  String toString() => message;
}

typedef TokenProvider = Future<String?> Function();

/// Thin JSON client for the SEA SPACE API. Adds the Supabase access token and maps
/// failures (offline, timeouts, HTTP errors) to [ApiException]s the UI can show.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenProvider,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 15),
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final TokenProvider tokenProvider;
  final Duration timeout;
  final http.Client _http;

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Object? body]) => _send('POST', path, body);
  Future<dynamic> patch(String path, Object body) => _send('PATCH', path, body);
  Future<dynamic> put(String path, Object body) => _send('PUT', path, body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final token = await tokenProvider();
    final request = http.Request(method, Uri.parse('$baseUrl$path'))..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _http.send(request).timeout(timeout));
    } on TimeoutException {
      throw const ApiException(ApiErrorKind.timeout, 'The server took too long to respond.');
    } on http.ClientException {
      // Covers offline / DNS / refused connections on both mobile (IOClient) and web.
      throw const ApiException(ApiErrorKind.network, 'No connection to the server. Check your network.');
    }

    final code = response.statusCode;
    if (code == 204 || response.body.isEmpty) return null;
    final decoded = _tryDecode(response.body);
    if (code >= 200 && code < 300) return decoded;

    final detail = _detail(decoded) ?? 'Request failed ($code)';
    throw ApiException(
      switch (code) {
        401 => ApiErrorKind.unauthorized,
        403 => ApiErrorKind.forbidden,
        404 => ApiErrorKind.notFound,
        409 => ApiErrorKind.conflict,
        422 => ApiErrorKind.validation,
        429 => ApiErrorKind.rateLimited,
        _ => ApiErrorKind.server,
      },
      detail,
      statusCode: code,
      details: decoded is Map && decoded['detail'] is Map
          ? (decoded['detail'] as Map).cast<String, dynamic>()
          : null,
    );
  }

  static dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  static String? _detail(dynamic decoded) {
    if (decoded is! Map) return null;
    final detail = decoded['detail'];
    if (detail is String) return detail;
    if (detail is Map && detail['message'] is String) return detail['message'] as String;
    if (detail is List && detail.isNotEmpty && detail.first is Map) {
      final first = detail.first as Map;
      final loc = (first['loc'] as List?)?.skip(1).join('.') ?? '';
      return '${loc.isEmpty ? '' : '$loc: '}${first['msg']}';
    }
    return null;
  }
}
