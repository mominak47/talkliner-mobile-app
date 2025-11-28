import 'package:flutter/material.dart';
import 'user_model.dart';

enum ChatType { individual, group }

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
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] as String,
      domainId: json['domain_id'] as String,
      chatType: ChatType.values.firstWhere((e) => e.name == json['chat_type']),
      participants:
          (json['participants'] as List<dynamic>)
              .map((e) => RecentParticipant.fromJson(e as Map<String, dynamic>))
              .toList(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      unreadCount: json['unread_count'] as int,
      isActive: json['is_active'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessage:
          json['last_message'] != null
              ? RecentLastMessage.fromJson(
                json['last_message'] as Map<String, dynamic>,
              )
              : null,
      settings: RecentSettings.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'domain_id': domainId,
    'chat_type': chatType,
    'participants': participants.map((e) => e.toJson()).toList(),
    'name': name,
    'description': description,
    'avatar': avatar,
    'unread_count': unreadCount,
    'is_active': isActive,
    'created_by': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'last_message': lastMessage?.toJson(),
    'settings': settings.toJson(),
  };
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
    debugPrint(json.toString());
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
  final String role;
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
    return RecentParticipant(
      userId: RecentUser.fromJson(json['user_id'] as Map<String, dynamic>),
      role: json['role'] as String,
      id: json['_id'] as String,
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
    'role': role,
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
