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
    return Column(
      children: [
        Consumer<ArticleDetailViewModel>(
          builder: (context, viewModel, _) {
            return LinearProgressIndicator(
              value: viewModel.ttsProgress,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            );
          },
        ),
        Consumer<ArticleDetailViewModel>(
          builder: (context, viewModel, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    viewModel.isPlaying && !viewModel.ttsService.isPaused
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.blue,
                  ),
                  onPressed: viewModel.toggleTTS,
                ),
                Text(
                  viewModel.isPlaying
                      ? (viewModel.ttsService.isPaused ? pauseText : playText)
                      : stopText,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
