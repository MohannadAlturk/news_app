import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  Function(double)? onProgress;
  bool isPaused = false;
  bool isPlaying = false;
  String? _remainingText;
  int _textLength = 0;  // Track the full length of the text

  TextToSpeechService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      isPlaying = true;
      isPaused = false;
    });

    _flutterTts.setCompletionHandler(() {
      isPlaying = false;
      isPaused = false;
      _remainingText = null;
      if (onProgress != null) onProgress!(1.0);  // Completion progress at 100%
    });

    _flutterTts.setCancelHandler(() {
      isPlaying = false;
      isPaused = false;
      _remainingText = null;
    });

    _flutterTts.setPauseHandler(() {
      isPlaying = false;
      isPaused = true;
    });

    _flutterTts.setContinueHandler(() {
      isPlaying = true;
      isPaused = false;
    });

    // Update progress based on the portion of the text spoken
    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      if (onProgress != null && _textLength > 0) {
        double progress = end / _textLength;  // Use the original text length
        onProgress!(progress);
      }
      _remainingText = text.substring(end);
    });
  }

  Future<void> speak(String text) async {
    isPlaying = true;
    isPaused = false;
    _remainingText = text;
    _textLength = text.length;  // Store text length for consistent progress tracking
    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    if (isPlaying) {
      await _flutterTts.pause();
      isPaused = true;
      isPlaying = false;
    }
  }

  Future<void> resume() async {
    if (isPaused && _remainingText != null) {
      await _flutterTts.speak(_remainingText!);
      isPlaying = true;
      isPaused = false;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    isPlaying = false;
    isPaused = false;
    _remainingText = null;
  }

  void setOnProgressHandler(Function(double)? handler) {
    onProgress = handler;
  }

  void dispose() {
    _flutterTts.stop();
  }
}
