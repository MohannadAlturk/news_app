import 'package:flutter/material.dart';

class InterestsViewModel {
  // List of interests with associated icons
  final List<Map<String, dynamic>> interests = [
    {'title': 'Business', 'icon': Icons.business},
    {'title': 'Entertainment', 'icon': Icons.movie},
    {'title': 'General', 'icon': Icons.public},
    {'title': 'Health', 'icon': Icons.health_and_safety},
    {'title': 'Science', 'icon': Icons.science},
    {'title': 'Sports', 'icon': Icons.sports},
    {'title': 'Technology', 'icon': Icons.computer},
  ];

  // Track selected interests
  List<String> selectedInterests = [];

  // Toggle interest selection
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }
}

