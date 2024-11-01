import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'package:news_app/services/language_service.dart';
import 'article_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    String languageCode = await LanguageService.getLanguageCode();
    setState(() {
      _currentLanguage = languageCode;
    });
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
        backgroundColor: Colors.white, // Set scaffold background color to white
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            getTranslatedText('your_news', _currentLanguage),
            style: const TextStyle(
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
              child: Container(
                color: Colors.white, // Ensure body content also has a white background
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: viewModel.articles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == viewModel.articles.length) {
                      return Column(
                        children: [
                          if (viewModel.isFetchingMore)
                            const Center(child: CircularProgressIndicator())
                          else
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  viewModel.fetchMoreArticles();
                                },
                                child: Text(
                                  getTranslatedText('load_more', _currentLanguage),
                                ),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      );
                    }

                    final article = viewModel.articles[index];
                    final formattedDate = viewModel.formatDate(article['publishedAt']);
                    final category = article['category'] ?? 'General';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(
                              article: article,
                            ),
                          ),
                        );
                      },
                      child: NewsCard(
                        article: article,
                        formattedDate: formattedDate,
                        category: category,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  String getTranslatedText(String key, String languageCode) {
    // Placeholder function for retrieving translations.
    return key;
  }
}
