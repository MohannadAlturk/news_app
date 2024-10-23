import 'dart:convert';
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


  // Fetch articles with pagination (limit of 20 articles per request)
  Future<List<dynamic>> fetchArticles({String category = 'general', int page = 1}) async {
    final url = Uri.parse('$_baseUrl/top-headlines?category=$category&pageSize=20&page=$page&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['articles'] != null) {
        return data['articles'];
      }
    }
    throw Exception('Failed to fetch news');
  }
}
