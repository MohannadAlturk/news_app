import 'package:flutter/material.dart';
import 'package:news_app/screens/news_screen.dart';
import '../widgets/interest_tile.dart';
import '../view_models/interests_view_model.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final InterestsViewModel viewModel = InterestsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent, // Keeps it transparent
            floating: true, // Ensures the AppBar stays visible when scrolling
            elevation: 4, // Adds slight shadow when scrolled
            centerTitle: true,
            title: Column(
              children: [
                const Text(
                  'What are your interests?',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "CupertinoSystemText",
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You can change them anytime in settings.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "CupertinoSystemText",
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                String interest = viewModel.interests[index];
                bool isSelected = viewModel.selectedInterests.contains(interest);
                return InterestTile(
                  interest: interest,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      viewModel.toggleInterest(interest);
                    });
                  },
                );
              },
              childCount: viewModel.interests.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsScreen()));
              print('Selected interests: ${viewModel.selectedInterests}');
            },
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "CupertinoSystemText",
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}
