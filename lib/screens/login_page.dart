import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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
import '../widgets/no_connection_widget.dart';
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
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShowing = false; // Tracks if the dialog is currently being shown
  ConnectivityResult _currentStatus = ConnectivityResult.none; // Tracks the current status

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    String languageCode = await LanguageService.getLanguageCode();
    await LanguageService.loadLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      debugPrint("Initial connectivity: $result");
      _handleConnectivityChange(result); // Handle initial connectivity
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    if (result[0] == ConnectivityResult.none) {
      _showNoConnectionDialog(); // Show dialog on no connectivity
    } else if (_isDialogShowing) {
      Navigator.pop(context); // Close dialog if connectivity is restored
      _isDialogShowing = false; // Reset the flag
    }
    if (result[0] == _currentStatus) {
      // No change in connectivity
      return;
    }
    _currentStatus = result[0]; // Update the current status
  }

  void _showNoConnectionDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true; // Lock dialog state
    debugPrint("Showing NoConnectionDialog.");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NoConnectionDialog(
          onRetry: () async {
            debugPrint("Retry pressed. Checking connectivity...");
            final result = await _connectivity.checkConnectivity();
            if (result[0] != ConnectivityResult.none) {
              debugPrint("Connection restored. Dismissing dialog.");
              Navigator.pop(context); // Close the dialog
              _isDialogShowing = false; // Reset the flag
            } else {
              debugPrint("Still no connection. Keeping dialog open.");
            }
          },
        );
      },
    ).whenComplete(() {
      debugPrint("Dialog dismissed. Resetting _isDialogShowing.");
      _isDialogShowing = false; // Ensure flag is reset after dismissal
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
            MaterialPageRoute(
                builder: (context) => const InterestsScreen(isFirstLogin: false)),
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

  Widget _buildForm() {
    final passwordVisibilityNotifier = ValueNotifier<bool>(true);
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
            onIconPressed: () {},
            onSubmitted: (_) {},
            obscureTextNotifier: ValueNotifier<bool>(false),
          ),
          const SizedBox(height: 10),
          InputFieldWidget(
            controller: _controllerPassword,
            hintText: getTranslatedText('password'),
            icon: passwordVisibilityNotifier.value
                ? Icons.visibility
                : Icons.visibility_off,
            onIconPressed: () {
              passwordVisibilityNotifier.value =
              !passwordVisibilityNotifier.value;
            },
            obscureTextNotifier: passwordVisibilityNotifier,
            onSubmitted: (_) {},
          ),
          const SizedBox(height: 10),
          ErrorMessageWidget(errorMessage: errorMessage),
          SubmitButtonWidget(
            isLogin: true,
            onPressed: _signIn,
            loginText: getTranslatedText('login'),
            registerText: getTranslatedText('register'),
          ),
          TextButton(
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
          ),
          TextButton(
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
          ),
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
                onLanguageChanged: (newLanguage) async {
                  await LanguageService.loadLanguage(newLanguage);
                  setState(() {
                    _currentLanguage = newLanguage;
                  });
                },
                currentLanguage: _currentLanguage,
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
