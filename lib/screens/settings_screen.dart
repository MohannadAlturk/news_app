import 'package:flutter/material.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/screens/login_page.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/widgets/bottom_navbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Change Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.interests, color: Colors.blue),
              onTap: () async {
                final interestsUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InterestsScreen()),
                );

                if (interestsUpdated == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Interests updated successfully.")),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.logout, color: Colors.blue),
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await Auth().signOut();
              Navigator.popUntil(context, (route) => route.isFirst); // Clear stack after sign-out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
