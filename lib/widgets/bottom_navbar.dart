import 'package:flutter/material.dart';
import 'package:news_app/screens/favorites_screen.dart';
import 'package:news_app/screens/news_screen.dart';
import 'package:news_app/screens/settings_screen.dart';
import 'package:news_app/screens/search_screen.dart';
import 'package:news_app/services/language_service.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onNewsTabTapped; // Callback for News reload

  const BottomNavBar({super.key, this.currentIndex = 0, this.onNewsTabTapped});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) {
      if (index == 0 && onNewsTabTapped != null) {
        onNewsTabTapped!(); // Trigger reload if on the News tab
      }
      return;
    }
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
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.menu), label: LanguageService.translate("news")),
        BottomNavigationBarItem(icon: const Icon(Icons.bookmark), label: LanguageService.translate("favorites")),
        BottomNavigationBarItem(icon: const Icon(Icons.search), label: LanguageService.translate("search")),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: LanguageService.translate("settings")),
      ],
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black45,
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 24),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
    );
  }
}

