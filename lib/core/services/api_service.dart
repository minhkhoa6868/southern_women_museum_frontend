import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../models/artifact_model.dart';
import '../../models/event_model.dart';
import '../../models/room_model.dart';

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
  String _language = 'en';

  static String _resolveBaseUrl(String? overrideBaseUrl) {
    if (overrideBaseUrl != null && overrideBaseUrl.isNotEmpty) {
      return overrideBaseUrl;
    }

    try {
      final envBaseUrl = dotenv.env['API_URL'];
      if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
        return envBaseUrl;
      }
    } catch (_) {
      // Tests may not initialize dotenv; fall back to the local API URL.
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

  // Set language for API requests
  void setLanguage(String language) {
    _language = language;
  }

  // Get current language
  String getLanguage() => _language;

  // Get headers with auth token
  Map<String, String> _getHeaders(
    Map<String, String>? additionalHeaders, {
    bool includeAuth = true,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      ...?additionalHeaders,
    };

    if (includeAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> postJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .post(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers, includeAuth: includeAuth),
          body: jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getJson({
    required String path,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .get(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers, includeAuth: includeAuth),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patchJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .patch(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers, includeAuth: includeAuth),
          body: jsonEncode(body),
        )
        .timeout(timeout);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> putJson({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final resolvedUrl = _joinUrl(baseUrl, path);

    final response = await _client
        .put(
          Uri.parse(resolvedUrl),
          headers: _getHeaders(headers, includeAuth: includeAuth),
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
      body: {'email': email, 'password': password},
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
    return patchJson(path: '/profile/update', body: {'language': languageCode});
  }

  Future<Map<String, dynamic>> updateNotificationSettings(
    bool isEnabled,
  ) async {
    return patchJson(
      path: '/profile/update',
      body: {'is_notification_enabled': isEnabled},
    );
  }

  void dispose() {
    _client.close();
  }

  // ─── Rooms ──────────────────────────────────────────────────────────────────

  Future<List<RoomModel>> getRooms() async {
    final response = await postJson(
      path: '/rooms/all',
      body: {'page': 1, 'limit': 100},
    );
    return _parsePaginatedList(response, RoomModel.fromJson);
  }

  Future<RoomModel> getRoomByCode(String code, {String? language}) async {
    final lang = language ?? _language;
    final response = await getJson(
      path: '/rooms?code=${Uri.encodeComponent(code)}&language=$lang',
      includeAuth: false,
    );

    final dynamic data = response['data'];
    if (data is Map<String, dynamic>) {
      return RoomModel.fromJson(data);
    }

    return RoomModel.fromJson(response);
  }

  // ─── Artifacts ──────────────────────────────────────────────────────────────
  /// Fetch a list of ALL artifacts for the global map search.
  Future<List<Artifact>> getAllArtifacts({
    String? language,
  }) async {
    final lang = language ?? _language;
    
    try {
      final response = await postJson(
        path: '/artifacts/all',
        body: {
          'page': 1, 
          'limit': 100, // Make sure this limit is high enough for all your artifacts!
          'filters': {}, // Empty filters means "get everything"
          'language': lang
        },
      );
      
      final list = _parsePaginatedList(response, Artifact.fromJson);
      // Optional: Sort them alphabetically by name for the search dropdown
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
      
    } on ApiException catch (e) {
      debugPrint('Failed to fetch all artifacts: $e');
      return [];
    }
  }

  Future<List<Artifact>> getRoomArtifacts(
    String roomId, {
    String? language,
  }) async {
    final lang = language ?? _language;
    Future<List<Artifact>> fetchWithFilters(
      Map<String, dynamic> filters,
    ) async {
      final response = await postJson(
        path: '/artifacts/all',
        // Server validates max limit = 100, keep under that to avoid 400 errors
        body: {'page': 1, 'limit': 100, 'filters': filters, 'language': lang},
      );
      final list = _parsePaginatedList(response, Artifact.fromJson);
      list.sort((a, b) => a.orderNo.compareTo(b.orderNo));
      return list;
    }

    try {
      return await fetchWithFilters({'roomId': roomId});
    } on ApiException catch (e) {
      if (e.statusCode != 400) rethrow;

      try {
        return await fetchWithFilters({'room_id': roomId});
      } on ApiException catch (e2) {
        if (e2.statusCode != 400) rethrow;
        return fetchWithFilters({'roomCode': roomId});
      }
    }
  }

  /// Fetch a list of random artifacts from the server.
  ///
  /// The backend may expose `/artifacts/random` which returns a JSON array.
  /// We include the current language as a query parameter and an optional
  /// `limit` to control how many items are returned.
  Future<List<Artifact>> getRandomArtifacts({
    String? language,
  }) async {
    final lang = language ?? _language;
    final query = '?language=${Uri.encodeComponent(lang)}';

    final response = await getJson(
      path: '/artifacts/random$query',
      includeAuth: true,
    );

    // response['data'] is expected to be a List of artifact JSON objects.
    final dynamic data = response['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Artifact.fromJson)
          .toList();
    }

    return [];
  }

  List<T> _parsePaginatedList<T>(
    Map<String, dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Normalize: some endpoints return { items: [...] } at top-level,
    // others return { data: { items: [...] } } or { data: [...] }.
    final dynamic data = response['data'] ?? response;
    List<dynamic>? items;

    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final inner = data['items'] ?? data['data'] ?? data['results'];
      if (inner is List) items = inner;
    }

    return items?.whereType<Map<String, dynamic>>().map(fromJson).toList() ??
        [];
  }

  // ─── Events ─────────────────────────────────────────────────────────────────

  Future<List<Event>> getEvents() async {
    final response = await getJson(path: '/events');

    final dynamic data = response['data'];

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Event.fromJson)
          .toList();
    }

    // Fallback: try paginated structure { data: { items: [...] } }
    return _parsePaginatedList(response, Event.fromJson);
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
