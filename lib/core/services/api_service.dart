import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models/event_model.dart';

const String fallbackApiUrl = 'http://localhost:3000/api';

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
  String? _authToken;

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

  // Set auth token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Get headers with auth token
  Map<String, String> _getHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      ...?additionalHeaders,
    };
    
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
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
          headers: _getHeaders(headers),
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
          headers: _getHeaders(headers),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patchJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .patch(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers),
          body: jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> putJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .put(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers),
          body: jsonEncode(body),
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

  // Auth endpoints
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return postJson(
      path: '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return postJson(
      path: '/auth/register',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  // User Profile endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    return getJson(path: '/profile/me');
  }

  Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    return patchJson(
      path: '/profile/update',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      },
    );
  }

  Future<Map<String, dynamic>> updateLanguage(String languageCode) async {
    return patchJson(
      path: '/profile/update',
      body: {'language': languageCode},
    );
  }

  Future<Map<String, dynamic>> updateNotificationSettings(bool isEnabled) async {
    return patchJson(
      path: '/profile/update',
      body: {'is_notification_enabled': isEnabled},
    );
  }

  void dispose() {
    _client.close();
  }

  Future<List<Event>> getEvents() async {
    // getJson returns a Map<String, dynamic>
    final response = await getJson(path: '/admin/events');
    
    final dynamic data = response['data'];

    if (data is List) {
      return data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    return [];
  }

  // Get only active events (đang diễn ra)
  Future<List<Event>> getActiveEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((e) => e.status == 'active').toList();
  }

  // Get upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((e) => e.status == 'upcoming').toList();
  }
}