import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/entry_field_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/submit_button_widget.dart';
import 'package:news_app/screens/register_page.dart';
import 'package:news_app/screens/forgot_password_page.dart';
import 'package:news_app/widgets/language_selector_widget.dart';

import '../services/firestore_service.dart';
import 'news_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool _isPasswordVisible = false;
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

  Future<void> _signIn() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final interests = await FirestoreService().getUserInterests();
        if (interests.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NewsScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InterestsScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = getTranslatedText('no_account_found', _currentLanguage);
            break;
          case 'wrong-password':
            errorMessage = getTranslatedText('incorrect_password', _currentLanguage);
            break;
          case 'invalid-email':
            errorMessage = getTranslatedText('badly_formatted_email', _currentLanguage);
            break;
          default:
            errorMessage = getTranslatedText('login_failed', _currentLanguage);
        }
      });
    }
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        );
      },
      child: Text(
        getTranslatedText('forgot_password', _currentLanguage),
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildRegisterInsteadButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      },
      child: Text(
        getTranslatedText('register_instead', _currentLanguage),
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0), // Add horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleWidget(title: getTranslatedText('login', _currentLanguage)),
          const SizedBox(height: 20),
          EntryFieldWidget(
            title: 'Email',
            controller: _controllerEmail,
          ),
          const SizedBox(height: 10), // Reduced spacing between fields
          EntryFieldWidget(
            title: 'Password',
            controller: _controllerPassword,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          ErrorMessageWidget(errorMessage: errorMessage),
          SubmitButtonWidget(
            isLogin: true,
            onPressed: _signIn,
          ),
          _buildForgotPasswordButton(),
          _buildRegisterInsteadButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Center(
          child: TitleWidget(title: getTranslatedText('news_app', _currentLanguage)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white, // Set the entire background color to white
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: _buildForm(),
              ),
            ),
            const Positioned(
              bottom: 16,
              right: 16,
              child: LanguageSelectorWidget(), // Positioned at the bottom-right corner
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
