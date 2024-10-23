import 'package:flutter/material.dart';

class LoginRegisterButtonWidget extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const LoginRegisterButtonWidget({
    Key? key,
    required this.isLogin,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }
}
