import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/article_detail_viewmodel.dart';

class TextToSpeechBar extends StatefulWidget {
  const TextToSpeechBar({super.key});

  @override
  _TextToSpeechBarState createState() => _TextToSpeechBarState();
}

class _TextToSpeechBarState extends State<TextToSpeechBar> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Set up progress handler
    final viewModel = Provider.of<ArticleDetailViewModel>(context, listen: false);
    viewModel.ttsService.setOnProgressHandler((progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ArticleDetailViewModel>(context);

    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                viewModel.isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: viewModel.toggleTTS,
            ),
            Text(
              viewModel.isPlaying ? 'Playing...' : 'Paused',
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    final viewModel = Provider.of<ArticleDetailViewModel>(context, listen: false);
    viewModel.ttsService.setOnProgressHandler(null); // Safely handles null
    super.dispose();
  }
}
