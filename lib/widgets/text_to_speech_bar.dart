import 'package:flutter/material.dart';
import '../services/text_to_speech_service.dart';

class TextToSpeechBar extends StatefulWidget {
  final String text;
  final TextToSpeechService ttsService;

  const TextToSpeechBar({
    super.key,
    required this.text,
    required this.ttsService,
  });

  @override
  _TextToSpeechBarState createState() => _TextToSpeechBarState();
}

class _TextToSpeechBarState extends State<TextToSpeechBar> {
  double _progress = 0.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.ttsService.setOnProgressHandler((progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  void _togglePlayPause() async {
    if (_isPlaying && !widget.ttsService.isPaused) {
      await widget.ttsService.pause();
    } else if (widget.ttsService.isPaused) {
      await widget.ttsService.resume();
    } else {
      setState(() {
        _progress = 0.0;
      });
      await widget.ttsService.speak(widget.text);
    }

    setState(() {
      _isPlaying = widget.ttsService.isPlaying || widget.ttsService.isPaused;
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
                _isPlaying && !widget.ttsService.isPaused ? Icons.pause : Icons.play_arrow,
                color: Colors.blue,
              ),
              onPressed: _togglePlayPause,
            ),
            Text(
              _isPlaying
                  ? (widget.ttsService.isPaused ? 'Paused' : 'Playing...')
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
    widget.ttsService.stop();
    widget.ttsService.setOnProgressHandler(null);
    super.dispose();
  }
}
