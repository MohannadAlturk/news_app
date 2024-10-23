import 'package:flutter/material.dart';

class LoginRegisterButtonWidget extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const LoginRegisterButtonWidget({
    super.key,
    required this.isLogin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }
}
