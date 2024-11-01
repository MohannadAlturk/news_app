import 'package:flutter/material.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/screens/login_page.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/widgets/bottom_navbar.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/language_selector_widget.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    String languageCode = await LanguageService.getLanguageCode();
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  void _onLanguageChanged(String newLanguage) {
    setState(() {
      _currentLanguage = newLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          getTranslatedText('settings', _currentLanguage),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white, // Set the background color to white for the entire body
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  getTranslatedText('change_interests', _currentLanguage),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.interests, color: Colors.blue),
                onTap: () async {
                  final interestsUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InterestsScreen()),
                  );

                  if (interestsUpdated == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getTranslatedText('interests_updated', _currentLanguage))),
                    );
                  }
                },
              ),
              ListTile(
                title: Text(
                  getTranslatedText('change_password', _currentLanguage),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.lock, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
              ),
              ListTile(
                title: Text(
                  getTranslatedText('delete_account', _currentLanguage),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.delete, color: Colors.red),
                onTap: () => _showDeleteAccountDialog(context),
              ),
              ListTile(
                title: Text(
                  getTranslatedText('sign_out', _currentLanguage),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.logout, color: Colors.blue),
                onTap: () => _showSignOutDialog(context),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslatedText('language', _currentLanguage),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    LanguageSelectorWidget(onLanguageChanged: _onLanguageChanged),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getTranslatedText('sign_out', _currentLanguage)),
        content: Text(getTranslatedText('sign_out_confirmation', _currentLanguage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(getTranslatedText('cancel', _currentLanguage)),
          ),
          TextButton(
            onPressed: () async {
              await Auth().signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text(getTranslatedText('sign_out', _currentLanguage)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getTranslatedText('delete_account', _currentLanguage)),
        content: Text(getTranslatedText('delete_account_confirmation', _currentLanguage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(getTranslatedText('cancel', _currentLanguage)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Auth().deleteUser();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(getTranslatedText('account_deleted', _currentLanguage))),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(getTranslatedText('account_delete_failed', _currentLanguage))),
                );
              }
            },
            child: Text(getTranslatedText('delete', _currentLanguage)),
          ),
        ],
      ),
    );
  }

  String getTranslatedText(String key, String languageCode) {
    // Placeholder function: Implement translation retrieval here using an external file or localization package.
    return key;
  }
}
