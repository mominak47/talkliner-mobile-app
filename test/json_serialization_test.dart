import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talkliner/app/models/chat_model.dart';

void main() {
  test('ChatModel serialization test', () {
    final chat = ChatModel(
      id: '123',
      domainId: 'domain_123',
      chatType: ChatType.individual,
      participants: [
        RecentParticipant(
          userId: RecentUser(
            id: 'user_1',
            username: 'user1',
            displayName: 'User One',
          ),
          role: Role.member,
          id: 'participant_1',
          joinedAt: DateTime.now(),
          lastSeen: DateTime.now(),
        ),
      ],
      name: 'Test Chat',
      unreadCount: 0,
      isActive: true,
      createdBy: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      settings: RecentSettings(muteNotifications: false, autoDeleteMessages: 0),
    );

    try {
      final jsonMap = chat.toJson();
      final jsonString = jsonEncode(jsonMap);
      debugPrint('Serialization successful: $jsonString');

      // Verify values
      expect(jsonMap['chat_type'], 'individual');
      expect(jsonMap['participants'][0]['role'], 'member');
    } catch (e) {
      fail('Serialization failed: $e');
    }
  });
}
