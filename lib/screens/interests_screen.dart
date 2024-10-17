import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Wähle deine Interessen aus'),
      ),
      body: ListView.builder(
        itemCount: viewModel.interests.length,
        itemBuilder: (context, index) {
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blue, // Background color of "Weiter" button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              print('Selected interests: ${viewModel.selectedInterests}');
            },
            child: const Text(
              'Weiter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}
