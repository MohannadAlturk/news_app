import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:news_app/services/firestore_service.dart';

class LanguageService {
  static Map<String, String> _localizedStrings = {};
  static String _currentLanguageCode = 'en';
  static final FirestoreService _firestoreService = FirestoreService();

  static Future<void> loadLanguage(String languageCode) async {
    try {
      _currentLanguageCode = languageCode;
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

    } catch (e) {
      print("Error loading language file: $e");
    }
  }

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static String getLanguageCode() {
    return _currentLanguageCode;
  }

  static Future<void> loadUserLanguage() async {
    String? languageCode = await _firestoreService.getUserLanguage();
    if (languageCode != null) {
      await loadLanguage(languageCode);
    } else {
      await loadLanguage(_currentLanguageCode);
    }
  }
}
