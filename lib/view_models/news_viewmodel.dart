import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../services/translation_service.dart';
import '/services/news_api_service.dart';
import '/services/firestore_service.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final TranslationService _translationService = TranslationService();

  List<dynamic> _articles = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;

  List<dynamic> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  Future<List<dynamic>> _fetchAndFilterArticles(List<String> interests, int page, {String language = 'en'}) async {
    List<dynamic> articles = [];

    for (String category in interests) {
      final fetchedArticles = await _newsApiService.fetchArticlesByCategory(category, page: page);

      articles.addAll(
        fetchedArticles.where((article) =>
        article['title'] != null &&
            article['publishedAt'] != null &&
            article['title'].isNotEmpty &&
            !article['title'].toLowerCase().contains('removed')
        ).toList(),
      );
    }

    // Shuffle to randomize display order
    articles.shuffle(Random());

    // Translate if the selected language is not English
    if (language != "en") {
      final translatedArticles = await _translationService.translateArticles(articles, language);
      if (translatedArticles != null) {
        // Replace original articles with translated ones
        for (int i = 0; i < articles.length; i++) {
          articles[i]['title'] = translatedArticles[i]['title'];
          articles[i]['description'] = translatedArticles[i]['description'];
        }
      }
    }

    return articles;
  }

  Future<void> fetchNewsArticles({bool refresh = false, String language = 'en'}) async {
    if (refresh) {
      _currentPage = 1;
      _articles.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user-selected interests (categories) from Firestore
      List<String> interests = await _firestoreService.getUserInterests();

      // Use helper function to fetch and filter articles with the specified language
      _articles = await _fetchAndFilterArticles(interests, _currentPage, language: language);

    } catch (error) {
      print('Error fetching articles: $error');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreArticles({String language = 'en'}) async {
    // Set _isFetchingMore to true and notify listeners to show loading indicator
    _isFetchingMore = true;
    notifyListeners();

    _currentPage++;

    try {
      List<String> interests = await _firestoreService.getUserInterests();

      // Fetch additional articles with the specified language
      final moreArticles = await _fetchAndFilterArticles(interests, _currentPage, language: language);

      _articles.addAll(moreArticles);

    } catch (error) {
      print('Error fetching more articles: $error');
    } finally {
      // Set _isFetchingMore to false and notify listeners to hide loading indicator
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // Function to format date as "Month Day, Year"
  String formatDate(String? publishedAt) {
    if (publishedAt != null) {
      try {
        DateTime dateTime = DateTime.parse(publishedAt);
        return DateFormat.yMMMMd().format(dateTime);
      } catch (e) {
        return 'Invalid date';
      }
    }
    return 'Unknown date';
  }
}
