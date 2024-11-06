import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'article_detail_screen.dart';
import 'package:news_app/services/firestore_service.dart';
import 'package:news_app/services/language_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
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
    Provider.of<NewsViewModel>(context, listen: false).fetchNewsArticles(language: _currentLanguage);
  }

  Future<void> _onFavoriteToggle(Map<String, dynamic> article) async {
    bool isFavorite = await _firestoreService.isFavorite(article);
    if (isFavorite) {
      await _firestoreService.removeArticleFromFavorites(article);
      _showSnackbar(getTranslatedText('removed_from_favorites'));
    } else {
      await _firestoreService.addArticleToFavorites(article);
      _showSnackbar(getTranslatedText('added_to_favorites'));
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  final category = getTranslatedText(article["category"].toString().toLowerCase());

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
                      isFavorite: false, // Favorites are managed only in FavoritesScreen
                      onFavoriteToggle: () => _onFavoriteToggle(article),
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
