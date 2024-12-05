import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/input_field_widget.dart';
import '../widgets/load_more_button_widget.dart';
import '/view_models/news_viewmodel.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'article_detail_screen.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/services/firestore_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  Future<void> _onFavoriteToggle(Map<String, dynamic> article) async {
    bool isFavorite = await _firestoreService.isFavorite(article);
    if (isFavorite) {
      await _firestoreService.removeArticleFromFavorites(article);
      _showSnackbar(getTranslatedText('removed_from_favorites'));
    } else {
      await _firestoreService.addArticleToFavorites(article, _currentLanguage);
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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(NewsViewModel viewModel, String query) async {
    // Clear previous results
    viewModel.clearQueryArticles();
    _searchController.clear();
    await viewModel.fetchArticlesByQuery(query, language: _currentLanguage);
    // Show a SnackBar if there's an error
    if (viewModel.errorMessage != null) {
      _showSnackbar(viewModel.errorMessage!);
      viewModel.clearErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          getTranslatedText("search_title"),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InputFieldWidget(
                  controller: _searchController,
                  hintText: getTranslatedText("search_query_placeholder"),
                  icon: Icons.search,
                  onIconPressed: () {
                    _performSearch(viewModel, _searchController.text);
                  },
                  onSubmitted: (query) {
                    _performSearch(viewModel, query);
                  },
                  obscureTextNotifier: ValueNotifier<bool>(false),
                ),
              ),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.queryArticles.isEmpty
                    ? Center(
                  child: Text(
                    getTranslatedText("no_results_found"),
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
                    : RefreshIndicator(
                  color: Colors.blue,
                  onRefresh: () async {
                    await viewModel.fetchArticlesByQuery(
                      _searchController.text,
                      language: _currentLanguage,
                    );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: viewModel.queryArticles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == viewModel.queryArticles.length) {
                        return Column(
                          children: [
                            if (viewModel.isFetchingMore)
                              const Center(
                                child: CircularProgressIndicator()
                              )
                            else if (viewModel.hasMoreQueryArticles)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: LoadMoreButtonWidget(
                                  onPressed: () {
                                    viewModel.fetchMoreArticlesByQuery(
                                      _currentLanguage,
                                    );
                                  },
                                    buttonText: getTranslatedText('load_more')
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        );
                      }

                      final article = viewModel.queryArticles[index];

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
                          formattedDate: article['formattedDate'],
                          category: "",
                          isFavorite: false,
                          onFavoriteToggle: () => _onFavoriteToggle(article),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
