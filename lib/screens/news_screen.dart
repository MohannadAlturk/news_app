import 'package:flutter/material.dart';
import '../services/news_api_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  List<dynamic> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetchTopHeadlines();
  }

  Future<void> _fetchTopHeadlines() async {
    try {
      List<dynamic> articles = await _newsApiService.fetchTopHeadlines(category: 'technology', country: 'us');
      setState(() {
        _articles = articles;
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top News'),
      ),
      body: _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return ListTile(
            title: Text(article['title']),
            subtitle: Text(article['description'] ?? 'No description available'),
            onTap: () {
              // Handle article tap (e.g., open detail page or link)
            },
          );
        },
      ),
    );
  }
}
