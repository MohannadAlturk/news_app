import 'package:flutter/material.dart';
import 'package:news_app/screens/favorites_screen.dart';
import 'package:news_app/screens/news_screen.dart';
import 'package:news_app/screens/settings_screen.dart';
import 'package:news_app/screens/search_screen.dart';
import 'package:news_app/services/language_service.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, this.currentIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid reloading the same page
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewsScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items:  [
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: getTranslatedText("news")),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: getTranslatedText("favorites")),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: getTranslatedText("settings")),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: getTranslatedText("search")),
      ],
      currentIndex: currentIndex,
      backgroundColor: Colors.white, // Ensure uniform background color
      //elevation: 0, // Remove shadow for a clean look
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black45,
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 24),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed, // Prevent shifting behavior
    );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
