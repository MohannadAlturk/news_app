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
    return SizedBox(
      width: double.infinity, // Knopf nimmt die volle Breite ein
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Primärfarbe
          foregroundColor: Colors.white, // Textfarbe
          padding: const EdgeInsets.symmetric(vertical: 16), // Höhe des Buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Abgerundete Ecken
          ),
          elevation: 0, // Flacher Button ohne Schatten
        ),
        child: Text(
          isLogin ? loginText : registerText,
          style: const TextStyle(
            fontSize: 16, // Konsistente Schriftgröße
            fontWeight: FontWeight.bold, // Fetter Text für Klarheit
          ),
        ),
      ),
    );
  }
}
