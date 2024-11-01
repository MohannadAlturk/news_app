import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';  // For loading API key from .env
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = dotenv.env['GEMINI_API_KEY']!;  // Load API key from .env


  Future<String?> translateArticlesJson(String articlesJsonString) async {
    // Set up the prompt for translating JSON content
    String prompt = """
Translate the following JSON content's 'title' and 'description' fields to ${jsonDecode(articlesJsonString)['targetLanguage']}.
Strictly return only the JSON structure, without any extra comments, explanations, or formatting.

$articlesJsonString
""";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'application/json', // Expecting JSON output
      ),
    );

    final chat = model.startChat(history: []);
    final content = Content.text(prompt);

    // Send the prompt to Gemini for translation
    final response = await chat.sendMessage(content);

    return response.text;  // Should return JSON as a string
  }

  // Method to summarize article content using Gemini 1.5 Flash API with a custom prompt
  Future<String?> summarizeArticle(String articleContent, {String? customPrompt}) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    // Create the custom prompt
    String prompt = customPrompt ??
        "Summarize the following article in a consise and well-written way."
            "It should be easy to understand and contain the most necessary information,"
            "to get a good understanding of it in a short amount of time."
            "Return it as plain text without any formatting.";
    final fullPrompt = '$prompt\n\n$articleContent';

    final chat = model.startChat(history: []);
    final content = Content.text(fullPrompt);

    // Send the custom prompt along with the article content to Gemini
    final response = await chat.sendMessage(content);

    return response.text;  // Return the summary generated by Gemini
  }
}
