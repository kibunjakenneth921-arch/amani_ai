import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_ai_provider.dart';
import 'openai_provider.dart';

abstract class AIProvider {
  /// Send a prompt and receive a stream of partial responses (for streaming UI)
  Stream<String> streamCompletion({required String prompt, String? conversationId});

  /// Send a prompt and get the full response (non-streaming)
  Future<String> complete({required String prompt, String? conversationId});
}

/// Global AI provider implementation selection.
/// Priority: Gemini (GEMINI_API_KEY) -> OpenAI (OPENAI_API_KEY) -> null
final aiProviderImpl = Provider<AIProvider?>((ref) {
  const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (geminiKey.isNotEmpty) return GeminiAIProvider(apiKey: geminiKey);

  const openaiKey = String.fromEnvironment('OPENAI_API_KEY');
  if (openaiKey.isNotEmpty) return OpenAIProvider(apiKey: openaiKey);

  return null;
});
