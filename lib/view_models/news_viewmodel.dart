import 'package:flutter/material.dart';
import '/services/news_api_service.dart';
import 'package:intl/intl.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  List<dynamic> _articles = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;

  List<dynamic> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  // Fetch articles for initial load or refresh
  Future<void> fetchNewsArticles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _articles.clear();
    }

    _isLoading = true;
    notifyListeners();
    try {
      final fetchedArticles = await _newsApiService.fetchArticles(category: 'science', page: _currentPage);

      // Ensure we filter out articles with missing or empty titles and missing published dates
      _articles.addAll(
        fetchedArticles.where((article) =>
        article['title'] != null && article['publishedAt'] != null &&
            article['title'].isNotEmpty
        ).toList(),
      );
    } catch (error) {
      print('Error fetching articles: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreArticles() async {
    _isFetchingMore = true;
    _currentPage++;
    try {
      final fetchedArticles = await _newsApiService.fetchArticles(category: 'science', page: _currentPage);

      // Ensure we filter out incomplete articles with missing or empty titles and missing published dates
      _articles.addAll(
        fetchedArticles.where((article) =>
        article['title'] != null && article['publishedAt'] != null &&
            article['title'].isNotEmpty
        ).toList(),
      );
    } catch (error) {
      print('Error fetching more articles: $error');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // Function to format date as DD-MM-YYYY
  String formatDate(String? publishedAt) {
    if (publishedAt != null) {
      try {
        DateTime dateTime = DateTime.parse(publishedAt);
        return DateFormat.yMMMMd().format(dateTime);  // Format date to "Month Day, Year"
      } catch (e) {
        return 'Invalid date';
      }
    }
    return 'Unknown date';
  }
}
