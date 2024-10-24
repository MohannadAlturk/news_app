import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../view_models/article_detail_viewmodel.dart';
import '../widgets/bottom_navbar.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'full_article_webview.dart';  // Import the web view screen

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
          title: Text(article['title'],
            style: const TextStyle(
              color: Colors.white,
            ),
          ),  // Display the article's title
          backgroundColor: Colors.blue,  // Set the app bar color to blue
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
                    const SizedBox(height: 20),

                    // Display the buttons side by side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Align the buttons
                      children: [
                        // "Read more" button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullArticleWebView(
                                  articleUrl: article['url'],  // Pass the article URL to the web view
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,  // Button color set to blue
                          ),
                          child: const Text('Read more',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),

                        // "Share" button
                        ElevatedButton.icon(
                          onPressed: () {
                            Share.share('Check this out: ${article['title']} - ${article['url']} - Sent with NewsAI');
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text('Share',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,  // Button color set to blue
                          ),
                        ),
                      ],
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
