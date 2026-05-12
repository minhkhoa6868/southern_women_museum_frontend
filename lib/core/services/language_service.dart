import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const _key = 'language_preference';
  static const _defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'vi'];

  String _language = _defaultLanguage;

  LanguageService() {
    _loadFromPrefs();
  }

  String get language => _language;

  Locale get locale => Locale(_language);

  bool get isVietnamese => _language == 'vi';
  bool get isEnglish => _language == 'en';

  /// Load language preference from SharedPreferences
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString(_key) ?? _defaultLanguage;
      if (!supportedLanguages.contains(_language)) {
        _language = _defaultLanguage;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
    }
  }

  /// Change language and persist to SharedPreferences
  Future<void> setLanguage(String newLanguage) async {
    if (!supportedLanguages.contains(newLanguage)) {
      debugPrint('Unsupported language: $newLanguage');
      return;
    }

    if (_language == newLanguage) return;

    _language = newLanguage;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newLanguage);
      debugPrint('Language changed to: $newLanguage');
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  /// Toggle between English and Vietnamese
  Future<void> toggleLanguage() async {
    final newLanguage = isVietnamese ? 'en' : 'vi';
    await setLanguage(newLanguage);
  }
}
