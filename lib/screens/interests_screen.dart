import 'package:flutter/material.dart';
import 'package:news_app/services/firestore_service.dart';
import 'package:news_app/widgets/interest_tile.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _selectedInterests = [];

  final List<Map<String, dynamic>> _interestsOptions = [
    {'title': 'Business', 'icon': Icons.business},
    {'title': 'Entertainment', 'icon': Icons.movie},
    {'title': 'General', 'icon': Icons.public},
    {'title': 'Health', 'icon': Icons.health_and_safety},
    {'title': 'Science', 'icon': Icons.science},
    {'title': 'Sports', 'icon': Icons.sports},
    {'title': 'Technology', 'icon': Icons.computer},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInterests();
  }

  Future<void> _loadUserInterests() async {
    final interests = await _firestoreService.getUserInterests();
    setState(() {
      _selectedInterests = interests;
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _saveInterests() async {
    await _firestoreService.saveUserInterests(_selectedInterests);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Select Your Interests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: _interestsOptions.length,
          itemBuilder: (context, index) {
            final interest = _interestsOptions[index]['title'] as String;
            final icon = _interestsOptions[index]['icon'] as IconData;
            final isSelected = _selectedInterests.contains(interest);

            return InterestTile(
              interest: interest,
              icon: icon,
              isSelected: isSelected,
              onTap: () => _toggleInterest(interest),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveInterests,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save),
      ),
    );
  }
}
