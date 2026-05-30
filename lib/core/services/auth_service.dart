import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../../models/auth_model.dart';

class AuthService with ChangeNotifier {
  final ApiService apiService;

  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  AuthService({required this.apiService}) {
    _loadTokenFromStorage();
  }

  // Getters
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null;
  User? get currentUser => _currentUser;

  // Load token from local storage on initialization
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      if (_accessToken != null) {
        apiService.setAuthToken(_accessToken);
        await getCurrentUser(); // Tự động lấy user info nếu có token
      }
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
      apiService.setAuthToken(token);
    } catch (e) {
      debugPrint('Error saving token to storage: $e');
    }
  }

  // Clear token from local storage
  Future<void> _clearTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      apiService.setAuthToken(null);
    } catch (e) {
      debugPrint('Error clearing token from storage: $e');
    }
  }

  // Get current user profile
  Future<bool> getCurrentUser() async {
    if (_accessToken == null) {
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.getCurrentUser();
      _currentUser = User.fromJson(response);

      // Update API service with user's language preference
      apiService.setLanguage(_currentUser!.language);

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

  // Update user profile
  Future<bool> updateUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    if (_accessToken == null) {
      _error = 'Not authenticated';
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.updateUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      _currentUser = User.fromJson(response);

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

  // Update user language preference
  Future<bool> updateUserLanguage(String languageCode) async {
    if (_accessToken == null) {
      _error = 'Not authenticated';
      return false;
    }

    if (_currentUser == null) {
      _error = 'Current user not loaded';
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.updateLanguage(languageCode);

      // Update current user with new language
      _currentUser = User.fromJson(response);

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

  // Login
  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.login(email: email, password: password);

      final accessToken = response['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        _error = 'Invalid response from server';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _accessToken = accessToken;
      await _saveTokenToStorage(accessToken);

      // Lấy thông tin user sau khi login thành công
      await getCurrentUser();

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
    _currentUser = null;
    await _clearTokenFromStorage();
    notifyListeners();
  }

  // Helper method to extract error message
  String _extractErrorMessage(String errorString) {
    if (errorString.contains('ApiException')) {
      final match = RegExp(
        r'ApiException\(\d+\):\s*(.+)',
      ).firstMatch(errorString);
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
