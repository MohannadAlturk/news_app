import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/entry_field_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/message_widget.dart';
import 'package:news_app/services/language_service.dart';
import '../widgets/language_selector_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? errorMessage = '';
  String? message = '';
  final TextEditingController _controllerEmail = TextEditingController();
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

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _controllerEmail.text);
      setState(() {
        message = getTranslatedText('password_reset_sent', _currentLanguage);
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getTranslatedText(e.code, _currentLanguage) ?? e.message;
      });
    }
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: TitleWidget(title: getTranslatedText('news_app', _currentLanguage)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TitleWidget(title: getTranslatedText('forgot_password', _currentLanguage)),
                  const SizedBox(height: 20),
                  EntryFieldWidget(
                    title: getTranslatedText('email', _currentLanguage),
                    controller: _controllerEmail,
                  ),
                  MessageWidget(message: message),
                  ErrorMessageWidget(errorMessage: errorMessage),
                  ElevatedButton(
                    onPressed: resetPassword,
                    child: Text(getTranslatedText('reset_password', _currentLanguage)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen (Login screen)
                    },
                    child: Text(
                      getTranslatedText('cancel', _currentLanguage),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: LanguageSelectorWidget(
                onLanguageChanged: _onLanguageChanged, // Pass the callback to update language
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTranslatedText(String key, String languageCode) {
    // Placeholder function: Implement translation retrieval here using an external file or localization package.
    return key;
  }
}
