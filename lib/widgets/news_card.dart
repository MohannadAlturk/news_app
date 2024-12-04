import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final String formattedDate;
  final String category;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle; // Callback for toggling favorite status

  const NewsCard({
    super.key,
    required this.article,
    required this.formattedDate,
    required this.category,
    required this.isFavorite,
    required this.onFavoriteToggle, // Inject the callback
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15), // Ensures the image respects the card's rounded corners
        child: Stack(
          children: [
            // Background Image
            if (article['urlToImage'] != null)
              Positioned.fill(
                child: Image.network(
                  article['urlToImage'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                  ), // Placeholder if the image fails to load
                ),
              ),

            // Darker semi-transparent overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7), // Increased opacity for better text visibility
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Use white for text visibility
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (article['description'] != null)
                    Text(
                      article['description'] ?? 'No description available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                article['source']?['name'] ?? 'Unknown Source',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onFavoriteToggle,
                        icon: Icon(
                          isFavorite ? Icons.delete : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
