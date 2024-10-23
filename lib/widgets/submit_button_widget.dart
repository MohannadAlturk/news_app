import 'package:flutter/material.dart';

class SubmitButtonWidget extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const SubmitButtonWidget({
    super.key,
    required this.isLogin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }
}
