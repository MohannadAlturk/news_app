import 'dart:convert';
import 'gemini_service.dart';

class TranslationService {
  final GeminiService _geminiService = GeminiService();

  String sanitizeJson(String jsonString) {
    // Step 1: Remove all double quotes from the JSON string
    jsonString = jsonString.replaceAll(RegExp(r'["“”„]'), '');

    // Step 2: Re-add necessary double quotes around JSON structure
    // Add quotes around "articles" key
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\barticles\b)(\s*:\s*\[)'), (match) => '"${match[1]}"${match[2]}');

    // Add quotes around "title" until it reaches "description"
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\btitle\b)(\s*:\s*)(.*?)(?=,description)'), (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Add quotes around "description" until it reaches the end of the object
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\bdescription\b)(\s*:\s*)(.*?)(?=\})'), (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Add quotes around "targetLanguage" and its value
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\btargetLanguage\b)(\s*:\s*)([^{},\]\[]+)'), (match) => '"${match[1]}"${match[2]}"${match[3]?.trim()}"');

    // Step 3: Final cleanup for JSON structure
    // Remove any stray trailing commas
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}');
    jsonString = jsonString.replaceAll(RegExp(r',\s*\]'), ']');

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
