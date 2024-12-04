import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/submit_button_widget.dart';
import 'package:news_app/screens/register_page.dart';
import 'package:news_app/screens/forgot_password_page.dart';
import 'package:news_app/widgets/language_selector_widget.dart';

import '../services/firestore_service.dart';
import '../widgets/input_field_widget.dart';
import 'news_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    await LanguageService.loadLanguage(languageCode);
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
            MaterialPageRoute(builder: (context) => const InterestsScreen(isFirstLogin: false)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = getTranslatedText('no_account_found');
            break;
          case 'wrong-password':
            errorMessage = getTranslatedText('incorrect_password');
            break;
          case 'invalid-email':
            errorMessage = getTranslatedText('badly_formatted_email');
            break;
          default:
            errorMessage = getTranslatedText('login_failed');
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
        getTranslatedText('forgot_password'),
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
        getTranslatedText('register_instead'),
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildForm() {
    final passwordVisibilityNotifier = ValueNotifier<bool>(true); // Default to obscure
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleWidget(title: getTranslatedText('login')),
          const SizedBox(height: 20),
          InputFieldWidget(
            controller: _controllerEmail,
            hintText: getTranslatedText('email'),
            icon: Icons.email,
            onIconPressed: () {}, // No specific functionality needed
            onSubmitted: (_) {}, // Optional submit behavior
            obscureTextNotifier: ValueNotifier<bool>(false), // Email field doesn't require obscure text
          ),
          const SizedBox(height: 10),
          InputFieldWidget(
            controller: _controllerPassword,
            hintText: getTranslatedText('password'),
            icon: passwordVisibilityNotifier.value
                ? Icons.visibility
                : Icons.visibility_off,
            onIconPressed: () {
              passwordVisibilityNotifier.value = !passwordVisibilityNotifier.value; // Toggle visibility
            },
            obscureTextNotifier: passwordVisibilityNotifier, // Pass notifier
            onSubmitted: (_) {}, // Optional submit behavior
          ),
          const SizedBox(height: 10),
          ErrorMessageWidget(errorMessage: errorMessage),
          SubmitButtonWidget(
            isLogin: true,
            onPressed: _signIn,
            loginText: getTranslatedText('login'),
            registerText: getTranslatedText('register'),
          ),
          _buildForgotPasswordButton(),
          _buildRegisterInsteadButton(),
        ],
      ),
    );
  }


  void _onLanguageChanged(String newLanguage) async {
    await LanguageService.loadLanguage(newLanguage);
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: Center(
          child: TitleWidget(title: getTranslatedText('news_app')),
        ),
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
            Positioned(
              bottom: 16,
              right: 16,
              child: LanguageSelectorWidget(
                onLanguageChanged: _onLanguageChanged,
                currentLanguage: LanguageService.getLanguageCode(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
