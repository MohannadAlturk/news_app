import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'article_detail_screen.dart';
import 'package:news_app/services/language_service.dart';


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
    await LanguageService.loadUserLanguage();
    String languageCode = await LanguageService.getLanguageCode();
    await LanguageService.loadLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
    // Fetch articles with the selected language
    Provider.of<NewsViewModel>(context, listen: false).fetchNewsArticles(language: _currentLanguage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, // Set scaffold background color to white
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            getTranslatedText('your_news'),
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
              onRefresh: () => viewModel.fetchNewsArticles(refresh: true, language: _currentLanguage),
              child: Container(
                color: Colors.white,
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
                                  viewModel.fetchMoreArticles(language: _currentLanguage);
                                },
                                child: Text(
                                  getTranslatedText('load_more'),
                                ),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      );
                    }

                    final article = viewModel.articles[index];
                    final formattedDate = viewModel.formatDate(article['publishedAt'], locale: _currentLanguage);
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
      );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
