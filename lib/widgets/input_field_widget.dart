import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final VoidCallback onIconPressed;
  final ValueNotifier<bool> obscureTextNotifier; // Use ValueNotifier for dynamic obscureText
  final ValueChanged<String> onSubmitted;

  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onIconPressed,
    required this.onSubmitted,
    required this.obscureTextNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: obscureTextNotifier,
      builder: (context, obscureText, _) {
        return TextField(
          controller: controller,
          obscureText: obscureText, // Use ValueNotifier's current value
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(icon, color: Colors.blue),
              onPressed: onIconPressed,
            ),
          ),
          cursorColor: Colors.blue,
          onSubmitted: onSubmitted,

        );
      },
    );
  }
}
