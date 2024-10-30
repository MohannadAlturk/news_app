import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  Function(double)? onProgress;

  TextToSpeechService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    // Set up progress tracking
    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      if (onProgress != null) {
        double progress = end / text.length;
        onProgress!(progress);
      }
    });
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  // Updated to accept null and default to a no-op if null is passed
  void setOnProgressHandler(Function(double)? handler) {
    onProgress = handler ?? (_) {};
  }

  void dispose() {
    _flutterTts.stop();
  }
}
