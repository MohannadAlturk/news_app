import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../services/gemini_service.dart';
import '../services/text_to_speech_service.dart';

class ArticleDetailViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final TextToSpeechService ttsService;

  String _summary = '';
  bool _isLoading = true;
  bool _isPlaying = false;
  double _ttsProgress = 0.0;

  String get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  double get ttsProgress => _ttsProgress;

  ArticleDetailViewModel(this.ttsService) {
    ttsService.setOnProgressHandler((progress) {
      _ttsProgress = progress;
      notifyListeners();
    });
  }

  Future<void> fetchAndSummarizeArticle(String articleUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      final scrapedContent = await _scrapeArticleContent(articleUrl);
      _summary = await _geminiService.summarizeArticle(scrapedContent) ?? 'No summary available.';
    } catch (error) {
      _summary = 'Failed to load article summary.';
      debugPrint('Error scraping or summarizing article: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTTS() async {
    if (_isPlaying) {
      await ttsService.stop();
      _ttsProgress = 0.0; // Reset progress on stop
    } else if (_summary.isNotEmpty) {
      await ttsService.speak(_summary);
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<String> _scrapeArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final paragraphs = document.getElementsByTagName('p');
        final articleText = paragraphs.map((p) => p.text).join('\n\n');
        if (articleText.isEmpty) throw Exception('No content found in article.');
        return articleText;
      } else {
        throw Exception('Failed to load article content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error scraping article: $error');
    }
  }

  @override
  void dispose() {
    ttsService.setOnProgressHandler(null); // Remove progress handler
    super.dispose();
  }
}
