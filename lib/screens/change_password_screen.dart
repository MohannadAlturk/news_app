import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/entry_field_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String? errorMessage = '';
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

  Future<void> _changePassword() async {
    try {
      // Reauthenticate the user with the current password
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getTranslatedText('password_changed_success', _currentLanguage))),
      );
      Navigator.pop(context); // Return to settings after password change
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedText('change_password', _currentLanguage)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntryFieldWidget(
              title: getTranslatedText('current_password', _currentLanguage),
              controller: _currentPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            EntryFieldWidget(
              title: getTranslatedText('new_password', _currentLanguage),
              controller: _newPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ErrorMessageWidget(errorMessage: errorMessage),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text(getTranslatedText('change_password_button', _currentLanguage)),
            ),
          ],
        ),
      ),
    );
  }

  String getTranslatedText(String key, String languageCode) {
    // Placeholder function for retrieving translations.
    return key;
  }
}
