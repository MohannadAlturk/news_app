import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];  // Load API key from .env

  // Method to summarize article content using Gemini 1.5 Flash API
  Future<String?> summarizeArticle(String articleContent) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey!,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: []);
    final content = Content.text(articleContent);

    // Send the article content and get a summary from Gemini
    final response = await chat.sendMessage(content);
    return response.text;  // Return the summary
  }
}
