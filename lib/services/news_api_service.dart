import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsApiService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String? apiKey = dotenv.env['NEWS_API_KEY']; // Fetch API key from .env

  // Fetch top headlines based on a category
  Future<List<dynamic>> fetchTopHeadlines({String category = 'general', String country = 'us'}) async {
    final url = Uri.parse('$_baseUrl/top-headlines?country=$country&category=$category&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['articles']; // Return the articles
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  // Fetch articles based on search query
  Future<List<dynamic>> fetchArticlesByQuery(String query) async {
    final url = Uri.parse('$_baseUrl/everything?q=$query&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['articles']; // Return the articles
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  // Fetch articles for a single category with pagination
  Future<List<dynamic>> fetchArticlesByCategory(String category, {int page = 1}) async {
    final url = Uri.parse('$_baseUrl/top-headlines?category=$category&pageSize=20&page=$page&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'] ?? [];

      // Add the category to each article
      return articles.map((article) {
        article['category'] = category;
        return article;
      }).toList();
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  // Fetch articles for multiple categories (interests) and shuffle them
  Future<List<dynamic>> fetchArticlesForInterests(List<String> interests, {int page = 1}) async {
    List<dynamic> allArticles = [];

    for (String interest in interests) {
      final articles = await fetchArticlesByCategory(interest, page: page);
      allArticles.addAll(articles);
    }

    // Shuffle the articles to randomize the order
    allArticles.shuffle(Random());
    return allArticles;
  }

}
