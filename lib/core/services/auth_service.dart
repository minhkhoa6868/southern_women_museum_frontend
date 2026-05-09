import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  final ApiService apiService;
  
  String? _accessToken;
  bool _isLoading = false;
  String? _error;

  AuthService({required this.apiService}) {
    _loadTokenFromStorage();
  }

  // Getters
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null;

  // Load token from local storage on initialization
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading token from storage: $e');
    }
  }

  // Save token to local storage
  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } catch (e) {
      debugPrint('Error saving token to storage: $e');
    }
  }

  // Clear token from local storage
  Future<void> _clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
    } catch (e) {
      debugPrint('Error clearing token from storage: $e');
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.login(
        email: email,
        password: password,
      );

      final accessToken = response['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        _error = 'Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _accessToken = accessToken;
      await _saveTokenToStorage(accessToken);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _accessToken = null;
    await _clearTokenFromStorage();
    notifyListeners();
  }

  // Helper method to extract error message
  String _extractErrorMessage(String errorString) {
    // Try to extract message from ApiException format: "ApiException(statusCode): message"
    if (errorString.contains('ApiException')) {
      final match = RegExp(r'ApiException\(\d+\):\s*(.+)').firstMatch(errorString);
      if (match != null) {
        return match.group(1) ?? 'An error occurred';
      }
    }
    return errorString.isNotEmpty ? errorString : 'An error occurred';
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
