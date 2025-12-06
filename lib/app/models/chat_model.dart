import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talkliner/app/models/message_model.dart';
import 'user_model.dart';
import 'package:talkliner/app/services/talkliner_service.dart';

enum ChatType { individual, group }

enum Role { admin, member }

class ChatModel {
  final String id;
  final String domainId;
  final ChatType chatType;
  final List<RecentParticipant> participants;
  final String? name;
  final String? description;
  final String? avatar;
  final int unreadCount;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RecentLastMessage? lastMessage;
  final RecentSettings settings;
  final List<MessageModel>? messages;

  ChatModel({
    required this.id,
    required this.domainId,
    required this.chatType,
    required this.participants,
    this.name,
    this.description,
    this.avatar,
    required this.unreadCount,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    required this.settings,
    this.messages,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? json['_id'] as String,
      domainId: json['domain_id'] as String,
      chatType: ChatType.values.firstWhere((e) => e.name == json['chat_type']),
      participants:
          (json['participants'] as List<dynamic>)
              .map((e) => RecentParticipant.fromJson(e as Map<String, dynamic>))
              .toList(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      unreadCount: 26, //json['unread_count'] as int,
      isActive: json['is_active'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      settings: RecentSettings.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      messages:
          json['messages'] != null
              ? (json['messages'] as List<dynamic>)
                  .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'domain_id': domainId,
    'chat_type': chatType.name,
    'participants': participants.map((e) => e.toJson()).toList(),
    'name': name,
    'description': description,
    'avatar': avatar,
    'unread_count': unreadCount,
    'is_active': isActive,
    'created_by': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'settings': settings.toJson(),
  };

  // Send Message
  ChatModel copyWith({
    String? id,
    String? domainId,
    ChatType? chatType,
    List<RecentParticipant>? participants, //
    String? name,
    String? description,
    String? avatar,
    int? unreadCount,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecentSettings? settings,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      chatType: chatType ?? this.chatType,
      participants: participants ?? this.participants,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      messages: messages ?? this.messages,
    );
  }

  // Send Message
  Future<http.Response> sendMessage(String content) async {
    try {
      var endpoint = "";
      if (chatType == ChatType.group) {
        endpoint = '/chats/${id}/messages';
        debugPrint("Message: $content : $endpoint");
      } else if (chatType == ChatType.individual) {
        RecentParticipant participant = participants.firstWhere(
          (e) => e.role == Role.member,
        );
        endpoint = '/chats/with/${participant.userId.id}';
        debugPrint("Message: $content : $endpoint");
      }

      // Chat Object
      SendMessageObject chatObject = SendMessageObject.fromJson({
        'content': content,
        'message_type': 'text',
        'file_url': '',
        'file_name': '',
        'file_size': '',
        'reply_to': '',
      });

      return TalklinerService.post(endpoint, body: chatObject.toJson());
    } catch (e) {
      debugPrint(e.toString());
      return http.Response(e.toString(), 500);
    }
  }

  // Get Chats
  Future<List<MessageModel>> getMessages({perPage = 10, page = 1}) async {
    debugPrint("[Chat_model.dart] : getMessages for : $id");
    var response = await TalklinerService.get(
      '/chats/$id?per_page=$perPage&page=$page',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load messages');
    }

    // If content type is json
    if (response.headers['content-type']?.contains('application/json') ??
        false) {
      Map<String, dynamic> jsonBody = jsonDecode(response.body);

      List<MessageModel> messages = [];
      if (jsonBody['data']['chat']['messages'] != null) {
        messages =
            (jsonBody['data']['chat']['messages'] as List)
                .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
                .toList();
        return messages;
      }

      return jsonBody['data']['chat'];
    }

    throw Exception('[Chat_model.dart] : Failed to load messages');
  }
}

class RecentLastMessage {
  final String content;
  final RecentUser senderId;
  final DateTime timestamp;

  RecentLastMessage({
    required this.content,
    required this.senderId,
    required this.timestamp,
  });

  factory RecentLastMessage.fromJson(Map<String, dynamic> json) {
    return RecentLastMessage(
      content: json['content'] ?? '',
      senderId:
          json['sender_id'] != null
              ? RecentUser.fromJson(json['sender_id'] as Map<String, dynamic>)
              : RecentUser(id: '', username: '', displayName: ''),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'sender_id': senderId.toJson(),
    'timestamp': timestamp.toIso8601String(),
  };
}

class RecentParticipant {
  final RecentUser userId;
  final Role role;
  final String id;
  final DateTime joinedAt;
  final DateTime lastSeen;
  final UserModel? user;

  RecentParticipant({
    required this.userId,
    required this.role,
    required this.id,
    required this.joinedAt,
    required this.lastSeen,
    this.user,
  });

  factory RecentParticipant.fromJson(Map<String, dynamic> json) {
    String id = json['id'] ?? json['_id'] as String;

    return RecentParticipant(
      userId: RecentUser.fromJson(json['user_id'] as Map<String, dynamic>),
      role: Role.values.firstWhere((e) => e.name == json['role']),
      id: id,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastSeen: DateTime.parse(json['last_seen'] as String),
      user:
          json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId.toJson(),
    'role': role.name,
    '_id': id,
    'joined_at': joinedAt.toIso8601String(),
    'last_seen': lastSeen.toIso8601String(),
    'user': user?.toJson(),
  };
}

class RecentUser {
  final String id;
  final String username;
  final String displayName;

  RecentUser({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory RecentUser.fromJson(Map<String, dynamic> json) {
    return RecentUser(
      id: json['_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'display_name': displayName,
  };
}

class RecentSettings {
  final bool muteNotifications;
  final int autoDeleteMessages;

  RecentSettings({
    required this.muteNotifications,
    required this.autoDeleteMessages,
  });

  factory RecentSettings.fromJson(Map<String, dynamic> json) {
    return RecentSettings(
      muteNotifications: json['mute_notifications'] as bool,
      autoDeleteMessages: json['auto_delete_messages'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'mute_notifications': muteNotifications,
    'auto_delete_messages': autoDeleteMessages,
  };
}

class SendMessageObject {
  final String content;
  final String messageType;
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final String replyTo;

  SendMessageObject({
    required this.content,
    required this.messageType,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.replyTo,
  });

  factory SendMessageObject.fromJson(Map<String, dynamic> json) {
    return SendMessageObject(
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as String,
      replyTo: json['reply_to'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'message_type': messageType,
    'file_url': fileUrl,
    'file_name': fileName,
    'file_size': fileSize,
    'reply_to': replyTo,
  };
}
