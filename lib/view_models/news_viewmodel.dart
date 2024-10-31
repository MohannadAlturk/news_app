import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '/services/news_api_service.dart';
import '/services/firestore_service.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final FirestoreService _firestoreService = FirestoreService();

  List<dynamic> _articles = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;

  List<dynamic> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  Future<List<dynamic>> _fetchAndFilterArticles(List<String> interests, int page) async {
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
    return articles;
  }


  Future<void> fetchNewsArticles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _articles.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user-selected interests (categories) from Firestore
      List<String> interests = await _firestoreService.getUserInterests();

      // Use helper function to fetch and filter articles
      _articles = await _fetchAndFilterArticles(interests, _currentPage);

    } catch (error) {
      print('Error fetching articles: $error');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreArticles() async {
    _isFetchingMore = true;
    _currentPage++;

    try {
      List<String> interests = await _firestoreService.getUserInterests();

      // Use helper function to fetch and filter additional articles
      final moreArticles = await _fetchAndFilterArticles(interests, _currentPage);

      _articles.addAll(moreArticles);

    } catch (error) {
      print('Error fetching more articles: $error');
    } finally {
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
