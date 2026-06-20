import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/components/conversation_session.dart';

class ConversationHistoryService extends ChangeNotifier {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  List<ConversationSession> sessions = [];
  late String csid;
  late DateTime startTime;
  List<ChatMessage> cMessages = [];
  bool isLoading = false;

  CollectionReference get _conversationsRef => db
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('conversations');

  void startSession() {
    csid = DateTime.now().millisecondsSinceEpoch.toString();
    startTime = DateTime.now();
    cMessages = [];
  }

  void addMessage(ChatMessage message) {
    cMessages.add(message);
  }

  Future<void> endSession() async {
    // Don't save empty conversations
    if (cMessages.isEmpty) return;
    final session = ConversationSession(
      id: csid,
      startTime: startTime,
      endTime: DateTime.now(),
      messages: List.from(cMessages),
      duration: DateTime.now().difference(startTime),
      personName: '',
    );

    await _conversationsRef.doc(csid).set(session.toJson());
    sessions.insert(0, session);
    notifyListeners();
  }

  Future<void> updatePersonName(String sessionId, String name) async {
    await _conversationsRef.doc(sessionId).update({'personName': name});

    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      sessions[index] = sessions[index].copyWith(personName: name);
      notifyListeners();
    }
  }

  /// Deletes a single conversation session, both from Firestore and the
  /// local in-memory list. Safe to call even if the session was already
  /// removed locally (e.g. double-tap) - just no-ops on the local side.
  Future<void> deleteSession(String sessionId) async {
    await _conversationsRef.doc(sessionId).delete();
    sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  /// Deletes every saved conversation for the current user.
  /// Uses a batched write so it's a single round-trip instead of N deletes.
  Future<void> deleteAllSessions() async {
    if (sessions.isEmpty) return;
    final batch = db.batch();
    for (final session in sessions) {
      batch.delete(_conversationsRef.doc(session.id));
    }
    await batch.commit();
    sessions.clear();
    notifyListeners();
  }

  Future<void> loadSessions() async {
    // Don't reload if already loaded
    if (sessions.isNotEmpty) return;
    isLoading = true;
    notifyListeners();
    final snapshot = await _conversationsRef
        .orderBy('startTime', descending: true)
        .get();

    sessions = snapshot.docs
        .map((doc) => ConversationSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    isLoading = false;
    notifyListeners();
  }

  // Refreshes the list of conversations
  Future<void> refreshSessions() async {
    isLoading = true;
    notifyListeners();

    final snapshot = await _conversationsRef
        .orderBy('startTime', descending: true)
        .get();

    sessions = snapshot.docs
        .map((doc) =>
            ConversationSession.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    isLoading = false;
    notifyListeners();
  }
}
