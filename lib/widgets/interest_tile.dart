import 'package:flutter/material.dart';

class InterestTile extends StatelessWidget {
  final String interest;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestTile({
    super.key,
    required this.interest,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[200] : Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isSelected ? Colors.blue : Colors.black),
            const SizedBox(height: 5),
            Text(interest, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
