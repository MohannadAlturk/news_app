import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/article_detail_viewmodel.dart';
import '../widgets/bottom_navbar.dart'; // Import the bottom navbar widget

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article; // Pass the full article object with the URL

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticleDetailViewModel()..fetchAndSummarizeArticle(article['url']),
      child: Scaffold(
        appBar: AppBar(
          title: Text(article['title']),  // Display the article's title
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<ArticleDetailViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());  // Show loading indicator while scraping and summarizing
              }

              return SingleChildScrollView(  // Wrap content in SingleChildScrollView to avoid overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'],  // Show the article title
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      viewModel.summary,  // Show the summary after it's generated
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: const BottomNavBar(), // Add the bottom navbar
      ),
    );
  }
}
