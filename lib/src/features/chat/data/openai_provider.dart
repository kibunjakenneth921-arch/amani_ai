import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'ai_provider.dart';

class OpenAIProvider implements AIProvider {
  final Dio _dio;
  final String apiKey;

  OpenAIProvider({required this.apiKey}) : _dio = Dio();

  @override
  Stream<String> streamCompletion({required String prompt, String? conversationId}) async* {
    final url = 'https://api.openai.com/v1/chat/completions';
    try {
      final response = await _dio.request<ResponseBody>(
        url,
        options: Options(method: 'POST', responseType: ResponseType.stream, headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        }),
        data: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'You are Amani AI, a compassionate reflective companion.'},
            {'role': 'user', 'content': prompt}
          ],
          'stream': true
        }),
      );

      final stream = response.data!.stream;
      final decoder = utf8.decoder;
      final buffer = StringBuffer();
      await for (final chunk in stream.transform(decoder)) {
        // OpenAI streams delta events separated by \n\n and lines starting with 'data: '
        buffer.write(chunk);
        final s = buffer.toString();
        final parts = s.split('\n\n');
        for (var part in parts) {
          if (part.trim().isEmpty) continue;
          if (part.trim() == '[DONE]') break;
          if (part.startsWith('data:')) {
            final jsonStr = part.replaceFirst('data:', '').trim();
            try {
              final decoded = jsonDecode(jsonStr);
              final choices = decoded['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] ?? {};
                final content = delta['content'] ?? '';
                if (content != null && content is String && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (_) {
              // ignore JSON parse errors until more data arrives
            }
          }
        }
        buffer.clear();
      }
    } catch (e) {
      yield '[OpenAI error: $e]';
    }
  }

  @override
  Future<String> complete({required String prompt, String? conversationId}) async {
    final url = 'https://api.openai.com/v1/chat/completions';
    final resp = await _dio.post(url,
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'You are Amani AI, a compassionate reflective companion.'},
            {'role': 'user', 'content': prompt}
          ]
        },
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}));
    if (resp.statusCode == 200) {
      try {
        final text = resp.data['choices'][0]['message']['content'] as String?;
        return text ?? '';
      } catch (e) {
        return '';
      }
    }
    throw Exception('OpenAI completion failed: ${resp.statusCode}');
  }
}
