import 'package:flutter/material.dart';
import 'package:news_app/services/firestore_service.dart';

class InterestsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Map<String, dynamic>> interests = [
    {'title': 'Business', 'icon': Icons.business},
    {'title': 'Entertainment', 'icon': Icons.movie},
    {'title': 'General', 'icon': Icons.public},
    {'title': 'Health', 'icon': Icons.health_and_safety},
    {'title': 'Science', 'icon': Icons.science},
    {'title': 'Sports', 'icon': Icons.sports},
    {'title': 'Technology', 'icon': Icons.computer},
  ];

  List<String> selectedInterests = [];

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }

  Future<void> saveInterestsToFirestore() async {
    await _firestoreService.saveUserInterests(selectedInterests);
  }

  Future<void> loadInterestsFromFirestore() async {
    selectedInterests = await _firestoreService.getUserInterests();
    notifyListeners();
  }
}
