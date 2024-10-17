import 'package:flutter/material.dart';

class InterestTile extends StatelessWidget {
  final String interest;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestTile({super.key,
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[200] : Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            interest,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "CupertinoSystemText"
            ),
          ),
        ),
      ),
    );
  }
}