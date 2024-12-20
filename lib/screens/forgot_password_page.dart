import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/message_widget.dart';
import 'package:news_app/services/language_service.dart';

import '../widgets/input_field_widget.dart';
import '../widgets/submit_button_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? errorMessage = '';
  String? message = '';
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> resetPassword() async {
    setState(() {
      errorMessage = null;
      message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _controllerEmail.text);
      setState(() {
        message = getTranslatedText('password_reset_sent');
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e);
        errorMessage = getTranslatedText('invalid-email');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: TitleWidget(title: getTranslatedText('news_app')),
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
                  TitleWidget(title: getTranslatedText('forgot_password')),
                  const SizedBox(height: 20),
                  InputFieldWidget(
                    controller: _controllerEmail,
                    hintText: getTranslatedText('email'),
                    icon: Icons.email,
                    onIconPressed: () {}, // No specific functionality needed
                    onSubmitted: (_) {}, // Optional submit behavior
                    obscureTextNotifier: ValueNotifier<bool>(false), // Email field doesn't require obscure text
                  ),
                  MessageWidget(message: message),
                  ErrorMessageWidget(errorMessage: errorMessage),
                  const SizedBox(height: 10),
                  SubmitButtonWidget(
                    isLogin: false,
                    onPressed: resetPassword,
                    loginText: getTranslatedText('login'),
                    registerText: getTranslatedText('reset_password'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      getTranslatedText('login'),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
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
