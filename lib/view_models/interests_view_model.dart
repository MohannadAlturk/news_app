class InterestsViewModel {
  // List of interests
  List<String> interests = [
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    "Technology"
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
