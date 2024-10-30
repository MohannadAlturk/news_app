import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/screens/interests_screen.dart';
import 'package:news_app/services/auth.dart';
import 'package:news_app/widgets/title_widget.dart';
import 'package:news_app/widgets/entry_field_widget.dart';
import 'package:news_app/widgets/error_message_widget.dart';
import 'package:news_app/widgets/submit_button_widget.dart';
import 'package:news_app/screens/register_page.dart';
import 'package:news_app/screens/forgot_password_page.dart';

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
            errorMessage = 'No account found for this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password, please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          default:
            errorMessage = 'Login failed. Please try again.';
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
      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
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
      child: const Text('Register instead', style: TextStyle(color: Colors.blue)),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const TitleWidget(title: 'Login'),
        const SizedBox(height: 20),
        EntryFieldWidget(
          title: 'Email',
          controller: _controllerEmail,
        ),
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
        ErrorMessageWidget(errorMessage: errorMessage),
        SubmitButtonWidget(
          isLogin: true,
          onPressed: _signIn,
        ),
        _buildForgotPasswordButton(),
        _buildRegisterInsteadButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Center(
          child: TitleWidget(title: 'News App'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: _buildForm(),
        ),
      ),
    );
  }
}
