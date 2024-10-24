import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;  // Import HTML parser
import '../services/gemini_service.dart';

class ArticleDetailViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  String _summary = '';
  bool _isLoading = true;

  String get summary => _summary;
  bool get isLoading => _isLoading;

  // Scrape the article content and summarize it
  Future<void> fetchAndSummarizeArticle(String articleUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Step 1: Scrape the article content from the URL
      final scrapedContent = await _scrapeArticleContent(articleUrl);

      // Step 2: Summarize the scraped content using Gemini 1.5 Flash
      _summary = (await _geminiService.summarizeArticle(scrapedContent))!;
    } catch (error) {
      print('Error scraping or summarizing article: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper function to scrape article content from the URL
  Future<String> _scrapeArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the HTML content
        final document = html_parser.parse(response.body);

        // Extract the text from <p> tags
        final paragraphs = document.getElementsByTagName('p');
        String articleText = '';
        for (var paragraph in paragraphs) {
          articleText += paragraph.text;
        }

        return articleText;
      } else {
        throw Exception('Failed to load article content');
      }
    } catch (error) {
      throw Exception('Error scraping article: $error');
    }
  }
}
