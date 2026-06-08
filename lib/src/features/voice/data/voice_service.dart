import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> initSpeech() async {
    return await _speech.initialize();
  }

  Future<void> startListening(Function(String) onResult) async {
    await _speech.listen(onResult: (result) {
      if (result.finalResult) onResult(result.recognizedWords);
    });
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }
}
