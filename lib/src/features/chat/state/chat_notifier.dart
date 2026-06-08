import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../data/ai_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/gemini_ai_provider.dart';

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier(ref.read));

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Reader read;
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  ChatNotifier(this.read) : super([]);

  Future<void> sendMessage(String conversationId, String text) async {
    final id = _uuid.v4();
    final message = ChatMessage(id: id, conversationId: conversationId, role: MessageRole.user, text: text, createdAt: Timestamp.now());
    state = [...state, message];
    await _firestore.collection('conversations').doc(conversationId).collection('messages').doc(id).set(message.toMap());

    final ai = read(aiProviderImpl);
    if (ai == null) {
      // No AI provider configured; add a placeholder response
      final respId = _uuid.v4();
      final resp = ChatMessage(id: respId, conversationId: conversationId, role: MessageRole.assistant, text: "AI provider not configured.", createdAt: Timestamp.now());
      state = [...state, resp];
      await _firestore.collection('conversations').doc(conversationId).collection('messages').doc(respId).set(resp.toMap());
      return;
    }

    // Streaming response
    final respId = _uuid.v4();
    var buffer = '';
    final assistantMessage = ChatMessage(id: respId, conversationId: conversationId, role: MessageRole.assistant, text: '', createdAt: Timestamp.now());
    state = [...state, assistantMessage];
    await _firestore.collection('conversations').doc(conversationId).collection('messages').doc(respId).set(assistantMessage.toMap());

    final stream = ai.streamCompletion(prompt: text, conversationId: conversationId);
    await for (final chunk in stream) {
      buffer += chunk;
      // optimistic update
      state = [for (final m in state) if (m.id == respId) ChatMessage(id: m.id, conversationId: m.conversationId, role: m.role, text: buffer, createdAt: m.createdAt) else m];
      await _firestore.collection('conversations').doc(conversationId).collection('messages').doc(respId).update({'text': buffer});
    }
  }

  Future<List<ChatMessage>> loadConversation(String conversationId, {int limit = 50}) async {
    final snap = await _firestore.collection('conversations').doc(conversationId).collection('messages').orderBy('createdAt', descending: false).limit(limit).get();
    final msgs = snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList();
    state = msgs;
    return msgs;
  }
}
