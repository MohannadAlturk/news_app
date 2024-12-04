import 'package:flutter/material.dart';
import 'package:news_app/services/firestore_service.dart';
import '/widgets/news_card.dart';
import '/widgets/bottom_navbar.dart';
import 'package:news_app/services/language_service.dart';
import 'article_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> favoriteArticles = [];
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadFavoriteArticles();
  }

  Future<void> _loadLanguage() async {
    await LanguageService.loadUserLanguage();
    String languageCode = await LanguageService.getLanguageCode();
    await LanguageService.loadLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  Future<void> _loadFavoriteArticles() async {
    favoriteArticles = await _firestoreService.getFavoriteArticles();
    setState(() {}); // Refresh the UI to display loaded favorites
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> article) async {
    await _firestoreService.removeArticleFromFavorites(article);
    favoriteArticles.removeWhere((favArticle) => favArticle['title'] == article['title']);
    setState(() {}); // Refresh the UI to reflect changes
  }

  String getTranslatedText(String key) {
    print(_currentLanguage);
    return LanguageService.translate(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          getTranslatedText('favorites_title'), // Use LanguageService for title
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Set the entire background to white
        child: favoriteArticles.isEmpty
            ? Center(
          child: Text(
            getTranslatedText('no_favorites'), // Translation for "No favorites added yet."
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadFavoriteArticles,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: favoriteArticles.length,
            itemBuilder: (context, index) {
              final article = favoriteArticles[index];

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
                  formattedDate: article["formattedDate"],
                  category: article["category"],
                  isFavorite: true, // All articles are favorites here
                  onFavoriteToggle: () => _removeFromFavorites(article), // Remove from favorites
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1), // Set index to reflect active tab
    );
  }
}
