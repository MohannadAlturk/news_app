import 'package:flutter/material.dart';

class SubmitButtonWidget extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;
  final String loginText;
  final String registerText;

  const SubmitButtonWidget({
    super.key,
    required this.isLogin,
    required this.onPressed,
    required this.loginText,
    required this.registerText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isLogin ? loginText : registerText),
    );
  }
}
