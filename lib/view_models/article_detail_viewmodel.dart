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
  double get ttsProgress => ttsService.progress; // Access progress directly

  ArticleDetailViewModel(this.ttsService) {
    // Set up progress updates from the TTS service
    ttsService.setOnProgressHandler((progress) {
      _ttsProgress = progress;
      notifyListeners(); // Notify listeners to update the UI when progress changes
      print("Progress updated in ViewModel: $_ttsProgress"); // Debug
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
    _ttsProgress = ttsService.progress;

    if (_isPlaying && ttsService.isPlaying) {
      // Pause without resetting progress
      await ttsService.pause();
    } else if (_summary.isNotEmpty) {
      // Only start from the beginning if progress is 0.0 and not paused
      if (_ttsProgress == 0.0 && !ttsService.isPaused) {
        await ttsService.speak(_summary); // Start a new playback
      } else {
        await ttsService.resume(); // Resume from last position
      }
    }

    _isPlaying = ttsService.isPlaying || ttsService.isPaused; // Reflect actual TTS state
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
