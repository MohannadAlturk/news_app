import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/load_more_button_widget.dart';
import '../widgets/no_connection_widget.dart';
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
  bool _shouldReload = false;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShowing = false; // Tracks if the dialog is currently being shown
  ConnectivityResult _currentStatus = ConnectivityResult.none; // Tracks the current status

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldReload) {
      _reloadArticles();
      _shouldReload = false;
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      debugPrint("Initial connectivity: $result");
      _handleConnectivityChange(result); // Handle initial connectivity
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (result[0] == ConnectivityResult.none) {
      _showNoConnectionDialog(); // Show dialog on no connectivity
    } else if (_isDialogShowing) {
      Navigator.pop(context); // Close dialog if connectivity is restored
      _isDialogShowing = false; // Reset the flag
    }
    if (result[0] == _currentStatus) {
      // No change in connectivity
      return;
    }
    _currentStatus = result[0]; // Update the current status
  }

  void _showNoConnectionDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true; // Lock dialog state
    debugPrint("Showing NoConnectionDialog.");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NoConnectionDialog(
          onRetry: () async {
            debugPrint("Retry pressed. Checking connectivity...");
            final result = await _connectivity.checkConnectivity();
            if (result[0] != ConnectivityResult.none) {
              debugPrint("Connection restored. Dismissing dialog.");
              Navigator.pop(context); // Close the dialog
              _isDialogShowing = false; // Reset the flag
            } else {
              debugPrint("Still no connection. Keeping dialog open.");
            }
          },
        );
      },
    ).whenComplete(() {
      debugPrint("Dialog dismissed. Resetting _isDialogShowing.");
      _isDialogShowing = false; // Ensure flag is reset after dismissal
    });
  }

  Future<void> _loadLanguage() async {
    await LanguageService.loadUserLanguage();
    String languageCode = await LanguageService.getLanguageCode();
    await LanguageService.loadLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
    _reloadArticles();
  }

  Future<void> _reloadArticles() async {
    final viewModel = Provider.of<NewsViewModel>(context, listen: false);
    viewModel.clearArticles(); // Clear current articles
    await viewModel.fetchNewsArticles(language: _currentLanguage);

    // Check for errors after fetching articles
    if (viewModel.errorMessage != null) {
      _showSnackbar(viewModel.errorMessage!);
      viewModel.clearErrorMessage();
    }
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

  void _triggerReload() {
    setState(() {
      _shouldReload = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          getTranslatedText('news'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.articles.isEmpty) {
            return Center(
              child: Text(
                getTranslatedText('no_results_found'),
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
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
                            padding: const EdgeInsets.all(30.0),
                            child: LoadMoreButtonWidget(
                              onPressed: () {
                                viewModel.fetchMoreArticles(language: _currentLanguage);
                              },
                              buttonText: getTranslatedText('load_more'),
                            ),
                          ),
                        const SizedBox(height: 80),
                      ],
                    );
                  }

                  final article = viewModel.articles[index];

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
                      category: article['category'],
                      isFavorite: false,
                      onFavoriteToggle: () => _onFavoriteToggle(article),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onNewsTabTapped: _triggerReload,
      ),
    );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
