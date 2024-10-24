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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          children: [
            const Text(
              'What are your interests?',
              style: TextStyle(
                fontSize: 24,
                fontFamily: "CupertinoSystemText",
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'You can change them anytime in settings.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: "CupertinoSystemText",
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Display interests in a grid layout
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,  // 2 tiles per row
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,  // Square tiles
                ),
                itemCount: viewModel.interests.length,
                itemBuilder: (context, index) {
                  final interest = viewModel.interests[index]['title'];
                  final icon = viewModel.interests[index]['icon'];
                  bool isSelected = viewModel.selectedInterests.contains(interest);

                  return InterestTile(
                    interest: interest,
                    icon: icon,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        viewModel.toggleInterest(interest);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
