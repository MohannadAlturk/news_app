import 'dart:convert';
import 'gemini_service.dart';

class TranslationService {
  final GeminiService _geminiService = GeminiService();

  String sanitizeJson(String jsonString) {
    // Remove control characters and ensure no trailing commas before parsing
    jsonString = jsonString.replaceAll(RegExp(r'[^\x20-\x7E]'), ''); // Remove non-ASCII characters
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}'); // Remove trailing commas
    jsonString = jsonString.replaceAll(RegExp(r',\s*\]'), ']'); // Remove trailing commas in lists
    jsonString = jsonString.trim(); // Trim whitespace
    return jsonString;
  }

  Future<List<dynamic>?> translateArticles(List<dynamic> articles, String language) async {
    // Convert articles list to JSON format for translation
    List<Map<String, dynamic>> articlesJson = articles.map((article) {
      return {
        'title': article['title'],
        'description': article['description'],
      };
    }).toList();

    // Create a single JSON object to send to the translation service
    String articlesJsonString = jsonEncode({
      'articles': articlesJson,
      'targetLanguage': language
    });

    // Call the Gemini service to translate JSON content
    String? translatedJsonString = await _geminiService.translateArticlesJson(articlesJsonString);

    if (translatedJsonString != null) {
      print('Raw Translated JSON response: $translatedJsonString');  // Debug print

      try {
        String sanitizedJsonString = sanitizeJson(translatedJsonString);
        print('Sanitized JSON response: $sanitizedJsonString');  // Debug print

        // Parse the sanitized JSON response
        List<dynamic> translatedArticles = jsonDecode(sanitizedJsonString)['articles'];
        return translatedArticles;
      } catch (e) {
        print('Error parsing translated JSON: $e');
        return null;
      }
    } else {
      print('Translation service returned null');
      return null;
    }
  }
}
