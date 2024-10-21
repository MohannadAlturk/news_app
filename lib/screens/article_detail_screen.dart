import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/article_detail_viewmodel.dart';
import '../widgets/bottom_navbar.dart'; // Import the bottom navbar widget
import 'package:intl/intl.dart'; // For formatting the date

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article; // Pass the full article object with the URL

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Unknown Date";
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(dateTime);  // Format date to "Month Day, Year"
    } catch (e) {
      return "Unknown Date";
    }
  }

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
                    // Display article image if available
                    if (article['urlToImage'] != null && article['urlToImage'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),  // Rounded corners for the image
                        child: Image.network(
                          article['urlToImage'],  // Display image from URL
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,  // Ensure the image fits the width properly
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Image not available',
                              style: TextStyle(color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Display the article title
                    Text(
                      article['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display the date and source in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(article['publishedAt']),  // Display formatted date
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          article['source']?['name'] ?? 'Unknown Source',  // Display source name
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Display the summary after it's generated
                    Text(
                      viewModel.summary,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
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
