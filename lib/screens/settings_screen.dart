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

  void _onLanguageChanged(String newLanguage) async{
    await LanguageService.loadLanguage(newLanguage);
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
          getTranslatedText('settings'),
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
                  getTranslatedText('change_interests'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.interests, color: Colors.blue),
                onTap: () async {
                  final interestsUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InterestsScreen(isFirstLogin: false)),
                  );

                  if (interestsUpdated == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getTranslatedText('interests_updated'))),
                    );
                  }
                },
              ),
              ListTile(
                title: Text(
                  getTranslatedText('change_password'),
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
                  getTranslatedText('sign_out'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.logout, color: Colors.blue),
                onTap: () => _showSignOutDialog(context),
              ),
              ListTile(
                title: Text(
                  getTranslatedText('delete_account'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                leading: const Icon(Icons.delete, color: Colors.red),
                onTap: () => _showDeleteAccountDialog(context),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslatedText('language'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    LanguageSelectorWidget(onLanguageChanged: _onLanguageChanged,
                      currentLanguage: _currentLanguage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(
          getTranslatedText('sign_out'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          getTranslatedText('sign_out_confirmation'),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              getTranslatedText('cancel'),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () async {
              await Auth().signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text(
              getTranslatedText('sign_out'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(
          getTranslatedText('delete_account'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          getTranslatedText('delete_account_confirmation'),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              getTranslatedText('cancel'),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () async {
              try {
                await Auth().deleteUser();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(getTranslatedText('account_deleted'))),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(getTranslatedText('account_delete_failed'))),
                );
              }
            },
            child: Text(
              getTranslatedText('delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
