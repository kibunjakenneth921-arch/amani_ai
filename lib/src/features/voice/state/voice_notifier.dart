import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/voice_service.dart';

final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());

final voiceNotifierProvider = StateNotifierProvider<VoiceNotifier, bool>((ref) => VoiceNotifier(ref.read));

class VoiceNotifier extends StateNotifier<bool> {
  final Reader read;

  VoiceNotifier(this.read) : super(false);

  Future<void> init() async {
    await read(voiceServiceProvider).initSpeech();
  }

  Future<void> startListening(Function(String) onResult) async {
    state = true;
    await read(voiceServiceProvider).startListening(onResult);
    state = false;
  }

  Future<void> stopListening() async {
    await read(voiceServiceProvider).stopListening();
    state = false;
  }

  Future<void> speak(String text) async {
    await read(voiceServiceProvider).speak(text);
  }
}
