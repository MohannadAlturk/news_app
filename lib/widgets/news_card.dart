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
            const SizedBox(height: 10),
            if (article['description'] != null)
              Text(
                article['description'] ?? 'No description available',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 12),

            // Row for date, source, and favorite icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expanded widget ensures the text doesn't overflow
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          formattedDate,  // Display formatted date
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          article['source']?['name'] ?? 'Unknown Source',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            overflow: TextOverflow.ellipsis,  // Truncate long text with ellipsis
                          ),
                          maxLines: 1,  // Ensure the text is on a single line
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite icon on the right
                IconButton(
                  onPressed: () {
                    // Add to favorites logic
                  },
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
