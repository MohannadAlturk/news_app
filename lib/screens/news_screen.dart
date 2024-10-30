import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'article_detail_screen.dart';  // Import the article detail screen

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNewsArticles(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Your News',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<NewsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading && viewModel.articles.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.fetchNewsArticles(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: viewModel.articles.length + 1, // Include the button at the end
                itemBuilder: (context, index) {
                  if (index == viewModel.articles.length) {
                    // Add a "Load More" button at the bottom
                    return Column(
                      children: [
                        if (viewModel.isFetchingMore)
                          const Center(child: CircularProgressIndicator())
                        else
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Fetch more articles when button is pressed
                                viewModel.fetchMoreArticles();
                              },
                              child: const Text('Load More'), // "Load More"
                            ),
                          ),
                        const SizedBox(height: 80), // Padding to avoid being covered by the navbar
                      ],
                    );
                  }

                  final article = viewModel.articles[index];
                  final formattedDate = viewModel.formatDate(article['publishedAt']);

                  // Pass the entire article object to the detail screen
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the ArticleDetailScreen when tapped, passing the entire article
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailScreen(
                            article: article,  // Pass the full article object
                          ),
                        ),
                      );
                    },
                    child: NewsCard(article: article, formattedDate: formattedDate),
                  );
                },
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }
}
