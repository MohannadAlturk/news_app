import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const _languageKey = 'selectedLanguage';

  // Loads the saved language code from SharedPreferences.
  static Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en'; // Default to English if not set
  }

  // Saves the language code to SharedPreferences.
  static Future<void> setLanguageCode(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
