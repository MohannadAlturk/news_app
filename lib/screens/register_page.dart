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
import 'package:news_app/screens/news_screen.dart';
import '../widgets/input_field_widget.dart';
import '../widgets/no_connection_widget.dart';
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
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShowing = false; // Tracks if the dialog is currently being shown
  ConnectivityResult _currentStatus = ConnectivityResult.none; // Tracks the current status

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
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

  Future<void> _createUser() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      final interestsSelected = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InterestsScreen(isFirstLogin: true),
        ),
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
            errorMessage = getTranslatedText('email_already_in_use');
            break;
          case 'invalid-email':
            errorMessage = getTranslatedText('invalid_email');
            break;
          case 'weak-password':
            errorMessage = getTranslatedText('weak_password');
            break;
          default:
            errorMessage = getTranslatedText('registration_failed');
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
        getTranslatedText('login_instead'),
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
          TitleWidget(title: getTranslatedText('register')),
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
            isLogin: false,
            onPressed: _createUser,
            loginText: getTranslatedText('login'),
            registerText: getTranslatedText('register'),
          ),
          _buildLoginInsteadButton(),
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
        centerTitle: true,
        title: TitleWidget(title: getTranslatedText('news_app')),
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

  String getTranslatedText(String key) {
    return LanguageService.translate(key);
  }
}
