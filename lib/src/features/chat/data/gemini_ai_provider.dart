import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'ai_provider.dart';

/// Gemini API provider implementation with configurable URL and basic SSE/JSONL parsing.
/// Set `GEMINI_API_KEY` and optionally `GEMINI_API_URL` via `--dart-define`.
class GeminiAIProvider implements AIProvider {
  final Dio _dio;
  final String apiKey;
  final String apiUrl;

  GeminiAIProvider({required this.apiKey, String? apiUrl})
      : _dio = Dio(),
        apiUrl = apiUrl ?? const String.fromEnvironment('GEMINI_API_URL', defaultValue: 'https://api.gemini.example.com/v1/streams');

  @override
  Stream<String> streamCompletion({required String prompt, String? conversationId}) async* {
    try {
      final options = Options(method: 'POST', responseType: ResponseType.stream, headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      });

      final response = await _dio.request<ResponseBody>(
        apiUrl,
        options: options,
        data: jsonEncode({'prompt': prompt, 'conversation_id': conversationId, 'stream': true}),
      );

      final stream = response.data!.stream;
      // Try to parse as SSE or JSONL. We'll accumulate string data and yield content chunks.
      final decoder = utf8.decoder;
      final buffer = StringBuffer();
      await for (final chunk in stream.transform(decoder)) {
        buffer.write(chunk);
        final accumulated = buffer.toString();
        // Split by newlines for JSONL or by double newline for SSE
        final parts = accumulated.split(RegExp(r'\n\n|\n'));
        for (var part in parts) {
          part = part.trim();
          if (part.isEmpty) continue;
          // SSE lines may start with 'data: '
          if (part.startsWith('data:')) {
            final payload = part.replaceFirst('data:', '').trim();
            if (payload == '[DONE]') return;
            try {
              final json = jsonDecode(payload);
              // Attempt to find text in known shape
              if (json is Map && json.containsKey('choices')) {
                final choices = json['choices'] as List<dynamic>;
                if (choices.isNotEmpty) {
                  final delta = choices[0]['delta'] ?? {};
                  final text = delta['content'] ?? choices[0]['text'] ?? '';
                  if (text is String && text.isNotEmpty) yield text;
                }
              }
            } catch (_) {
              // Not JSON — yield raw
              yield payload;
            }
          } else {
            // Try JSON parse
            try {
              final json = jsonDecode(part);
              if (json is Map && json.containsKey('text')) {
                final t = json['text'];
                if (t is String) yield t;
              } else if (json is Map && json.containsKey('choices')) {
                final choices = json['choices'] as List<dynamic>;
                if (choices.isNotEmpty) {
                  final msg = choices[0]['message'] ?? choices[0]['delta'] ?? {};
                  final text = msg['content'] ?? msg['text'] ?? '';
                  if (text is String && text.isNotEmpty) yield text;
                }
              } else {
                // fallback
                yield part;
              }
            } catch (_) {
              yield part;
            }
          }
        }
        buffer.clear();
      }
    } catch (e) {
      yield '[Error: $e]';
    }
  }

  @override
  Future<String> complete({required String prompt, String? conversationId}) async {
    final url = apiUrl.replaceAll('/streams', '/complete');
    final resp = await _dio.post(url, data: {'prompt': prompt, 'conversation_id': conversationId}, options: Options(headers: {'Authorization': 'Bearer $apiKey'}));
    if (resp.statusCode == 200) {
      if (resp.data is Map && resp.data.containsKey('text')) return resp.data['text'] ?? '';
      return resp.data.toString();
    }
    throw Exception('Gemini completion failed: ${resp.statusCode}');
  }
}
