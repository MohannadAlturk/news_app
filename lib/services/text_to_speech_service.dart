import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  Function(double)? onProgress;
  String? _originalText;
  int _lastEndPosition = 0; // Tracks last known position
  bool isPaused = false;
  bool isPlaying = false;

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
      _resetProgress();
      if (onProgress != null) onProgress!(1.0); // Completion at 100%
    });

    _flutterTts.setCancelHandler(() {
      isPlaying = false;
      isPaused = false;
      _resetProgress();
    });

    _flutterTts.setPauseHandler(() {
      isPlaying = false;
      isPaused = true;
    });

    _flutterTts.setContinueHandler(() {
      isPlaying = true;
      isPaused = false;
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      _lastEndPosition = end;
      if (onProgress != null && _originalText != null) {
        double progress = end / _originalText!.length;
        onProgress!(progress);
      }
    });
  }

  Future<void> speak(String text) async {
    _originalText = text;
    _lastEndPosition = 0; // Reset start position on new speak
    await _speakFromPosition();
    isPlaying = true;
    isPaused = false;
  }

  Future<void> _speakFromPosition() async {
    if (_originalText != null) {
      String remainingText = _originalText!.substring(_lastEndPosition);
      await _flutterTts.speak(remainingText);
    }
  }

  Future<void> pause() async {
    if (isPlaying && !isPaused) {
      await _flutterTts.pause();
      isPaused = true;
      isPlaying = false;
    }
  }

  Future<void> resume() async {
    if (isPaused) {
      await _speakFromPosition(); // Resume from last known position
      isPlaying = true;
      isPaused = false;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    isPlaying = false;
    isPaused = false;
    _resetProgress();
  }

  void _resetProgress() {
    _lastEndPosition = 0;
    onProgress?.call(0.0);
  }

  void setOnProgressHandler(Function(double)? handler) {
    onProgress = handler;
  }

  void dispose() {
    _flutterTts.stop();
  }
}