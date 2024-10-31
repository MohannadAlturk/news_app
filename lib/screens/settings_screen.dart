import 'package:flutter/material.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/screens/login_page.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/widgets/bottom_navbar.dart';
import 'change_password_screen.dart';

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
              title: const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.lock, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Delete Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () => _showDeleteAccountDialog(context),
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Auth().deleteUser();
                Navigator.popUntil(context, (route) => route.isFirst); // Clear stack after account deletion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted successfully.")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete account: $e")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}