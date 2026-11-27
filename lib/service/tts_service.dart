import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureInit();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}
