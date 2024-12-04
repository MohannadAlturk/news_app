import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/services/language_service.dart';
import 'dart:math';
import '../services/translation_service.dart';
import '/services/news_api_service.dart';
import '/services/firestore_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final TranslationService _translationService = TranslationService();

  List<dynamic> _articles = [];
  final List<dynamic> _queryArticles = [];
  List<dynamic> _allQueryArticles = []; // Holds all fetched articles for the query

  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;

  List<dynamic> get articles => _articles;
  List<dynamic> get queryArticles => _queryArticles;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  int _displayedCount = 0; // Keeps track of the number of displayed articles
  final int _batchSize = 10; // Number of articles to display per batch

  // Getter to check if there are more query articles to load
  bool get hasMoreQueryArticles => _displayedCount < _allQueryArticles.length;

  Future<List<dynamic>> _fetchAndFilterArticles(List<String> interests,
      int page, {String language = 'en'}) async {
    List<dynamic> articles = [];

    for (String category in interests) {
      final fetchedArticles = await _newsApiService.fetchArticlesByCategory(
          category, page: page);

      articles.addAll(
        fetchedArticles.where((article) =>
        article['title'] != null &&
            article['publishedAt'] != null &&
            article['title'].isNotEmpty &&
            !article['title'].toLowerCase().contains('removed') &&
            article["description"] != null
        ).toList(),
      );
    }

    // Shuffle to randomize display order
    articles.shuffle(Random());

    for (int i = 0; i < articles.length; i++) {
      articles[i]["formattedDate"] = formatDate(articles[i]["publishedAt"], locale: language);
      articles[i]["category"] = LanguageService.translate(articles[i]["category"].toString().toLowerCase());
    }

    // Translate articles if the selected language is not English
    if (language != "en") {
      final translatedArticles = await _translationService.translateArticles(
          articles, language);
      if (translatedArticles != null) {
        for (int i = 0; i < articles.length; i++) {
          articles[i]['title'] = translatedArticles[i]['title'];
          articles[i]['description'] = translatedArticles[i]['description'];
        }
      }
    }

    return articles;
  }

  Future<void> fetchNewsArticles(
      {bool refresh = false, String language = 'en'}) async {
    if (refresh) {
      _currentPage = 1;
      _articles.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user-selected interests (categories) from Firestore
      List<String> interests = await _firestoreService.getUserInterests();

      // Fetch and translate articles
      _articles = await _fetchAndFilterArticles(
          interests, _currentPage, language: language);
    } catch (error) {
      print('Error fetching articles: $error');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreArticles({String language = 'en'}) async {
    _isFetchingMore = true;
    notifyListeners();

    _currentPage++;

    try {
      List<String> interests = await _firestoreService.getUserInterests();

      // Fetch and translate additional articles
      final moreArticles = await _fetchAndFilterArticles(
          interests, _currentPage, language: language);

      _articles.addAll(moreArticles);
    } catch (error) {
      print('Error fetching more articles: $error');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchArticlesByQuery(String query, {String language = 'en'}) async {
    _isLoading = true;
    _displayedCount = 0;
    _queryArticles.clear();
    _allQueryArticles.clear();
    notifyListeners();

    try {
      final results = await _newsApiService.fetchArticlesByQuery(query);

      // Filter and format articles
      final validResults = results.where((article) =>
      article['description'] != null &&
          article['description'] != 'removed').toList();

      for (int i = 0; i < validResults.length; i++) {
        validResults[i]["formattedDate"] = formatDate(validResults[i]["publishedAt"], locale: language);
        validResults[i]["category"] = "";
      }

      _allQueryArticles = validResults; // Store all filtered and formatted articles

      // Ensure the first batch is loaded before setting isLoading to false
      await _loadNextBatch(language);
    } catch (error) {
      print('Error fetching query articles: $error');
      _allQueryArticles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNextBatch(String language) async {
    if (!hasMoreQueryArticles) {
      return; // No more articles to display
    }

    _isFetchingMore = true;
    notifyListeners();

    try {
      // Get the next batch of valid articles
      final nextBatch = _allQueryArticles.skip(_displayedCount).take(_batchSize).toList();

      if (language != 'en') {
        final translatedBatch = await _translationService.translateArticles(nextBatch, language);
        if (translatedBatch != null) {
          for (int i = 0; i < nextBatch.length; i++) {
            nextBatch[i]['title'] = translatedBatch[i]['title'];
            nextBatch[i]['description'] = translatedBatch[i]['description'];
          }
        }
      }

      _queryArticles.addAll(nextBatch);
      _displayedCount += nextBatch.length;
    } catch (error) {
      print('Error loading next batch: $error');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }


  void clearQueryArticles() {
    _queryArticles.clear();
    _allQueryArticles.clear();
    _displayedCount = 0;
    notifyListeners();
  }

  void clearArticles() {
    _articles.clear();
    _isLoading = true; // Ensure loading spinner shows
    notifyListeners();
  }


  Future<void> fetchMoreArticlesByQuery(String language) async {
    if (_isFetchingMore) return;
    await _loadNextBatch(language);
  }

  String formatDate(String? publishedAt, {String locale = 'en'}) {
    if (publishedAt != null) {
      try {
        initializeDateFormatting(locale);
        DateTime dateTime = DateTime.parse(publishedAt);
        return DateFormat.yMMMMd(locale).format(
            dateTime); // Use locale parameter
      } catch (e) {
        return 'Invalid date';
      }
    }
    return 'Unknown date';
  }
}
