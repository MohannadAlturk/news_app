import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/services/language_service.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import '../widgets/submit_button_widget.dart';
import '../widgets/title_widget.dart';
import '../widgets/input_field_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String? errorMessage = '';

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  Future<void> _changePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getTranslatedText('password_changed_success'))),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = getTranslatedText('incorrect_password');
            break;
          case 'weak-password':
            errorMessage = getTranslatedText('weak_password');
            break;
          default:
            errorMessage = getTranslatedText('default_error');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordVisibilityNotifier = ValueNotifier<bool>(true); // Default to obscure

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          getTranslatedText('change_password'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleWidget(title: getTranslatedText('change_password')),
            const SizedBox(height: 20),
            InputFieldWidget(
              controller: _currentPasswordController,
              hintText: getTranslatedText('current_password'),
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
            InputFieldWidget(
              controller: _newPasswordController,
              hintText: getTranslatedText('new_password'),
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
              onPressed: _changePassword,
              loginText: getTranslatedText('change_password_button'),
              registerText: getTranslatedText('register'),
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
