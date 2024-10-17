class InterestsViewModel {
  // List of interests
  List<String> interests = [
    'Politik',
    'Informatik',
    'Technologie',
    'Gaming',
    'Beauty',
    'Business'
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
