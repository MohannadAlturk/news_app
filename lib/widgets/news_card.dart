import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final String formattedDate;

  const NewsCard({
    super.key,
    required this.article,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (article['description'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  article['description'] ?? 'No description available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$formattedDate • ${article['source']['name'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add to favorites logic here
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
