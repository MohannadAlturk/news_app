import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/article_detail_viewmodel.dart';

class TextToSpeechBar extends StatelessWidget {
  final String text;

  const TextToSpeechBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator that listens directly to ArticleDetailViewModel's ttsProgress
        Consumer<ArticleDetailViewModel>(
          builder: (context, viewModel, _) {
            return LinearProgressIndicator(
              value: viewModel.ttsProgress, // Directly access ttsProgress from Provider
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
                        ? Icons.pause // Show pause if playing and not paused
                        : Icons.play_arrow, // Show play if stopped or paused
                    color: Colors.blue,
                  ),
                  onPressed: viewModel.toggleTTS,
                ),
                Text(
                  viewModel.isPlaying
                      ? (viewModel.ttsService.isPaused ? 'Paused' : 'Playing...')
                      : 'Stopped',
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
