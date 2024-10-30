import 'package:flutter/material.dart';

class EntryFieldWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool obscureText; // Neuen Parameter hinzufügen
  final Widget? suffixIcon; // Neuen Parameter hinzufügen

  const EntryFieldWidget({
    required this.title,
    required this.controller,
    this.obscureText = false, // Standardwert setzen
    this.suffixIcon, // Optionales Widget
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, // Verwendung des neuen Parameters
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: suffixIcon, // Verwendung des neuen Parameters
      ),
    );
  }
}

