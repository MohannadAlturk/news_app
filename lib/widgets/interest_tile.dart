import 'package:flutter/material.dart';

class InterestTile extends StatelessWidget {
  final String interest;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;  // Add the icon data

  const InterestTile({
    super.key,
    required this.interest,
    required this.isSelected,
    required this.onTap,
    required this.icon,  // Require an icon
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[200] : Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: isSelected ? Colors.blue : Colors.black),  // Display the icon
            const SizedBox(height: 10),
            Text(
              interest,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
