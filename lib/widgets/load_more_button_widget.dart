import 'package:flutter/material.dart';

class LoadMoreButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const LoadMoreButtonWidget({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Button takes the full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Primary color
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(vertical: 16), // Height of the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          elevation: 0, // Flat button with no shadow
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16, // Consistent font size
            fontWeight: FontWeight.bold, // Bold text for clarity
          ),
        ),
      ),
    );
  }
}
