import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;

  const TitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0), // Abstand von oben
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 32, // Großer Text
            color: Colors.lightBlue.shade400, // Mittel helles Blau
            fontWeight: FontWeight.bold, // optional, um den Text fett zu machen
          ),
        ),
      ),
    );
  }
}
