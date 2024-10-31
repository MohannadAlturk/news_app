import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider to access TextToSpeechService
import '../services/text_to_speech_service.dart';

class TextToSpeechBar extends StatefulWidget {
  final String text;

  const TextToSpeechBar({
    super.key,
    required this.text,
  });

  @override
  _TextToSpeechBarState createState() => _TextToSpeechBarState();
}

class _TextToSpeechBarState extends State<TextToSpeechBar> {
  double _progress = 0.0;
  bool _isPlaying = false;
  late TextToSpeechService ttsService;

  @override
  void initState() {
    super.initState();
    ttsService = Provider.of<TextToSpeechService>(context, listen: false);
    ttsService.setOnProgressHandler((progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  void _togglePlayPause() async {
    if (_isPlaying && !ttsService.isPaused) {
      await ttsService.pause();
    } else if (ttsService.isPaused) {
      await ttsService.resume();
    } else {
      setState(() {
        _progress = 0.0;
      });
      await ttsService.speak(widget.text);
    }

    setState(() {
      _isPlaying = ttsService.isPlaying || ttsService.isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                _isPlaying && !ttsService.isPaused ? Icons.pause : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: _togglePlayPause,
            ),
            Text(
              _isPlaying
                  ? (ttsService.isPaused ? 'Paused' : 'Playing...')
                  : 'Stopped',
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    ttsService.stop();
    ttsService.setOnProgressHandler(null);
    super.dispose();
  }
}
