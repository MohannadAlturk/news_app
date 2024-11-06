import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  Function(double)? onProgress;
  String? _originalText;
  int _lastEndPosition = 0;
  int _currentPosition = 0;
  bool isPaused = false;
  bool isPlaying = false;
  double _progress = 0.0;
  Timer? _progressTimer;

  TextToSpeechService() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      isPlaying = true;
      isPaused = false;
      _startProgressFallback();
    });

    _flutterTts.setCompletionHandler(() {
      isPlaying = false;
      isPaused = false;
      _progress = 0.0; // Reset progress to 0
      _lastEndPosition = 0;
      _progressTimer?.cancel(); // Stop fallback timer

      // Notify the progress listener to reset the progress bar
      onProgress?.call(_progress);
      print("Playback complete, resetting to stopped state");
    });

    _flutterTts.setCancelHandler(() {
      isPlaying = false;
      isPaused = false;
      _progress = 0.0;
      _lastEndPosition = 0;
      _progressTimer?.cancel();
      onProgress?.call(_progress);
    });

    _flutterTts.setPauseHandler(() {
      isPlaying = false;
      isPaused = true;
      _lastEndPosition = _currentPosition;
      _progressTimer?.cancel();
    });

    _flutterTts.setContinueHandler(() {
      isPlaying = true;
      isPaused = false;
      _startProgressFallback(); // Restart fallback timer
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      if (_originalText != null) {
        // Adjust end position to be relative to the last known position
        _currentPosition = _lastEndPosition + end;

        // Calculate progress as a fraction of the total text length
        double calculatedProgress = _currentPosition / _originalText!.length;

        // Only update progress if it moves forward
        if (calculatedProgress > _progress) {
          _progress = calculatedProgress;
          onProgress?.call(_progress);
          print("Progress updated in TextToSpeechService: $_progress");
        }
      }
    });

  }

  Future<void> speak(String text, {String languageCode = 'en', bool isResuming = false}) async {
    _originalText = text;
    if (!isResuming) {
      _lastEndPosition = 0;
      _progress = 0.0;
    }
    await _setLanguage(languageCode);

    await _speakFromPosition();
    isPlaying = true;
    isPaused = false;
  }

  Future<void> _speakFromPosition() async {
    if (_originalText != null) {
      String remainingText = _originalText!.substring(_lastEndPosition);
      print("Speaking from position $_lastEndPosition");
      await _flutterTts.speak(remainingText);
    }
  }

  Future<void> _setLanguage(String languageCode) async {
    switch (languageCode) {
      case 'en':
        await _flutterTts.setLanguage("en-US");
        break;
      case 'de':
        await _flutterTts.setLanguage("de-DE");
        break;
      default:
        await _flutterTts.setLanguage("en-US");
        print("Language code $languageCode not supported, defaulting to English.");
    }
  }

  Future<void> pause() async {
    if (isPlaying && !isPaused) {
      await _flutterTts.pause();
      isPaused = true;
      isPlaying = false;
      _lastEndPosition = _currentPosition;
      _progressTimer?.cancel();
      print("Paused at position $_lastEndPosition");
    }
  }

  Future<void> resume() async {
    if (isPaused) {
      await _speakFromPosition();
      isPlaying = true;
      isPaused = false;
      _startProgressFallback();
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    isPlaying = false;
    isPaused = false;
    _progress = 0.0;
    _lastEndPosition = 0;
    _progressTimer?.cancel();
    print("Stopped playback, resetting positions");
  }

  double get progress => _progress;

  void setOnProgressHandler(Function(double)? handler) {
    onProgress = handler;
  }

  void _startProgressFallback() {
    _progressTimer?.cancel(); // Cancel any existing timer
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isPlaying && onProgress != null) {
        onProgress!(_progress);
        print("Fallback progress: $_progress");
      }
    });
  }

  void dispose() {
    _flutterTts.stop();
    _progressTimer?.cancel();
  }
}
