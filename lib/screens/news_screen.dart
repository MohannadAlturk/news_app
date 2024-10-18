import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Scroll event is now handled in the Consumer
      // Remove Provider access from here
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsViewModel()..fetchNewsArticles(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Deine Nachrichten',
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
                controller: _scrollController, // Attach the scroll controller here
                padding: const EdgeInsets.all(8.0),
                itemCount: viewModel.articles.length + 1, // Additional item for "Scrollen Sie nach unten für mehr"
                itemBuilder: (context, index) {
                  if (index == viewModel.articles.length) {
                    // Handle scroll event for fetching more articles
                    if (!viewModel.isFetchingMore && _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
                      // Fetch more articles when user reaches the bottom
                      viewModel.fetchMoreArticles();
                    }

                    return Column(
                      children: [
                        if (viewModel.isFetchingMore)
                          const Center(child: CircularProgressIndicator())
                        else
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Scrollen Sie nach unten für mehr',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        const SizedBox(height: 80), // Padding to avoid being covered by the navbar
                      ],
                    );
                  }

                  final article = viewModel.articles[index];
                  final formattedDate = viewModel.formatDate(article['publishedAt']);
                  return NewsCard(article: article, formattedDate: formattedDate);
                },
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}