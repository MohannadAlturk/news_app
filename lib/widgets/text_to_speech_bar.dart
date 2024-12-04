import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/article_detail_viewmodel.dart';

class TextToSpeechBar extends StatelessWidget {
  final String text;
  final String playText;
  final String pauseText;
  final String stopText;

  const TextToSpeechBar({
    super.key,
    required this.text,
    required this.playText,
    required this.pauseText,
    required this.stopText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Top and bottom spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Consumer<ArticleDetailViewModel>(
            builder: (context, viewModel, _) {
              return LinearProgressIndicator(
                value: viewModel.ttsProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 4, // Slim progress bar
              );
            },
          ),
          const SizedBox(height: 12), // Space between progress bar and controls
          Consumer<ArticleDetailViewModel>(
            builder: (context, viewModel, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: viewModel.toggleTTS,
                    icon: Icon(
                      viewModel.isPlaying && !viewModel.ttsService.isPaused
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.blue,
                    ),
                    iconSize: 28, // Standard icon size
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  Text(
                    viewModel.isPlaying
                        ? (viewModel.ttsService.isPaused ? playText : pauseText)
                        : playText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
