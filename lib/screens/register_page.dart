import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/entry_field_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/submit_button_widget.dart';
import 'package:news_app/screens/news_screen.dart';

import '../widgets/language_selector_widget.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? errorMessage = '';
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
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

  Future<void> _createUser() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      final interestsSelected = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InterestsScreen()),
      );

      if (interestsSelected == true && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewsScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = getTranslatedText('email_already_in_use', _currentLanguage);
            break;
          case 'invalid-email':
            errorMessage = getTranslatedText('invalid_email', _currentLanguage);
            break;
          case 'weak-password':
            errorMessage = getTranslatedText('weak_password', _currentLanguage);
            break;
          default:
            errorMessage = getTranslatedText('registration_failed', _currentLanguage);
        }
      });
    }
  }

  Widget _buildLoginInsteadButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: Text(
        getTranslatedText('login_instead', _currentLanguage),
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          EntryFieldWidget(
            title: 'Email',
            controller: _controllerEmail,
          ),
          const SizedBox(height: 10),
          EntryFieldWidget(
            title: 'Password',
            controller: _controllerPassword,
            obscureText: true,
          ),
          const SizedBox(height: 10),
          ErrorMessageWidget(errorMessage: errorMessage),
          SubmitButtonWidget(
            isLogin: false,
            onPressed: _createUser,
          ),
          _buildLoginInsteadButton(),
        ],
      ),
    );
  }

  void _onLanguageChanged(String newLanguage) {
    print(_currentLanguage);
    setState(() {
      _currentLanguage = newLanguage;
    });
    print(_currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: TitleWidget(title: getTranslatedText('news_app', _currentLanguage)),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: _buildForm(),
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
