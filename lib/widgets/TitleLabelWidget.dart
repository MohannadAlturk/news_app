import 'package:flutter/material.dart';

class TitleLabelWidget extends StatelessWidget {
  final String label;

  const TitleLabelWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Abstand nach unten
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24, // Größerer Text
          fontWeight: FontWeight.bold, // Fett
        ),
      ),
    );
  }
}
