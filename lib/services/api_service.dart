import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const String fallbackApiUrl = 'http://10.0.2.2:3000/api';
// const String fallbackApiUrl = 'http://localhost:3000/api';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = _resolveBaseUrl(baseUrl);

  final http.Client _client;
  final String baseUrl;

  static String _resolveBaseUrl(String? overrideBaseUrl) {
    if (overrideBaseUrl != null && overrideBaseUrl.isNotEmpty) {
      return overrideBaseUrl;
    }

    final envBaseUrl = dotenv.env['API_URL'];
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    return fallbackApiUrl;
  }

  static String _joinUrl(String base, String path) {
    final cleanBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  Future<Map<String, dynamic>> postJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .post(
          Uri.parse(resolvedUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            ...?headers,
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getJson({
    required String path,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .get(
          Uri.parse(resolvedUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            ...?headers,
          },
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decodedBody = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      return <String, dynamic>{'data': decodedBody};
    }

    throw ApiException(
      response.statusCode,
      _extractMessage(decodedBody) ?? response.reasonPhrase ?? 'Request failed',
    );
  }

  dynamic _decodeResponseBody(String responseBody) {
    if (responseBody.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(responseBody);
    } catch (_) {
      return responseBody;
    }
  }

  String? _extractMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      final message = decodedBody['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (decodedBody is String && decodedBody.isNotEmpty) {
      return decodedBody;
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
