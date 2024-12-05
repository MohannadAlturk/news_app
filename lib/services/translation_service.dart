import 'dart:convert';
import 'gemini_service.dart';

class TranslationService {
  final GeminiService _geminiService = GeminiService();

  String sanitizeJson(String jsonString) {
    // Step 1: Remove problematic symbols
    jsonString = jsonString.replaceAll(RegExp(r'[“”„]'), ''); // Remove fancy quotes
    jsonString = jsonString.replaceAll(r'\\', r'\\\\'); // Properly escape backslashes

    // Step 2: Add necessary double quotes around JSON structure
    // Add quotes around "articles" key
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\barticles\b)(\s*:\s*\[)'), (match) => '"${match[1]}"${match[2]}');

    // Add quotes around "title" until it reaches "description"
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\btitle\b)(\s*:\s*)(.*?)(?=,\s*description\b)'),
            (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Add quotes around "description" until it reaches the end of the object or another key
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\bdescription\b)(\s*:\s*)(.*?)(?=[,}])'),
            (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Add quotes around "targetLanguage" and its value
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\btargetLanguage\b)(\s*:\s*)([^{},\]\[]+)'),
            (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Step 3: Final cleanup
    // Remove any stray trailing commas
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}');
    jsonString = jsonString.replaceAll(RegExp(r',\s*\]'), ']');

    // Step 4: Validate brackets (optional safety step)
    jsonString = jsonString.trim();
    if (!jsonString.startsWith('{') || !jsonString.endsWith('}')) {
      jsonString = '{$jsonString}';
    }

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

    const int maxRetries = 3; // Maximum number of retries
    int attempt = 0; // Current retry attempt
    String? translatedJsonString;

    while (attempt < maxRetries) {
      attempt++;
      try {
        // Call the Gemini service to translate JSON content
        translatedJsonString = await _geminiService.translateArticlesJson(articlesJsonString);

        if (translatedJsonString != null) {
          print('Raw Translated JSON response (Attempt $attempt): $translatedJsonString'); // Debug print

          // Sanitize the JSON string
          String sanitizedJsonString = sanitizeJson(translatedJsonString);
          print('Sanitized JSON response (Attempt $attempt): $sanitizedJsonString'); // Debug print

          // Parse the sanitized JSON response
          List<dynamic> translatedArticles = jsonDecode(sanitizedJsonString)['articles'];
          return translatedArticles;
        }
      } catch (e) {
        print('Error parsing translated JSON (Attempt $attempt): $e');
        if (attempt == maxRetries) {
          print('Max retries reached. Unable to translate articles.');
          return Future.error('Error translating articles. Please try again later.');
        }
      }
    }

    return null; // In case all retries fail
  }
}
