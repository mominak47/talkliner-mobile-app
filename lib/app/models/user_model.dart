import 'package:flutter/material.dart';
import 'package:talkliner/app/models/chat_model.dart';

class UserSettings {
  final bool pushToTalk;
  final bool emergencyAlertCall;
  final bool gpsLocation;
  final bool groupCall;
  final bool individualCall;
  final bool messaging;
  final bool videoCall;
  final bool callHistory;

  UserSettings({
    required this.pushToTalk,
    required this.emergencyAlertCall,
    required this.gpsLocation,
    required this.groupCall,
    required this.individualCall,
    required this.messaging,
    required this.videoCall,
    required this.callHistory,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      pushToTalk: json['push_to_talk'] ?? false,
      emergencyAlertCall: json['emergency_alert_call'] ?? false,
      gpsLocation: json['gps_location'] ?? false,
      groupCall: json['group_call'] ?? false,
      individualCall: json['individual_call'] ?? false,
      messaging: json['messaging'] ?? false,
      videoCall: json['video_call'] ?? false,
      callHistory: json['call_history'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_to_talk': pushToTalk,
      'emergency_alert_call': emergencyAlertCall,
      'gps_location': gpsLocation,
      'group_call': groupCall,
      'individual_call': individualCall,
      'messaging': messaging,
      'video_call': videoCall,
      'call_history': callHistory,
    };
  }
}

class UserModel {
  final String id;
  final String domainId;
  final String username;
  final String displayName;
  final UserSettings settings;
  final String isOnline;
  final String status;
  final String fcmToken;
  final String apnToken;
  final String? chatId;
  final String? profilePicture;
  UserModel({
    required this.id,
    required this.domainId,
    required this.username,
    required this.displayName,
    required this.settings,
    required this.isOnline,
    required this.status,
    required this.fcmToken,
    required this.apnToken,
    this.chatId,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      domainId: json['domain_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? '',
      settings: UserSettings.fromJson(json['settings'] ?? {}),
      isOnline: json['is_online'] ?? '',
      status: json['status'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
      apnToken: json['apn_token'] ?? '',
      chatId: json['chat_id'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'domain_id': domainId,
      'username': username,
      'display_name': displayName,
      'settings': settings.toJson(),
      'is_online': isOnline,
      'status': status,
      'fcm_token': fcmToken,
      'apn_token': apnToken,
      'chat_id': chatId,
      'profile_picture': profilePicture,
    };
  }

  ChatModel createChat() {
    ChatModel chat = ChatModel(
      id: '',
      domainId: domainId,
      chatType: ChatType.individual,
      participants: [
        // Add Self
        RecentParticipant(
          userId: RecentUser(
            id: id,
            username: username,
            displayName: displayName,
          ),
          role: Role.member,
          id: id,
          joinedAt: DateTime.now(),
          lastSeen: DateTime.now(),
          user: this,
        ),
      ],
      name: displayName,
      description: null,
      avatar: null,
      unreadCount: 0,
      isActive: false,
      createdBy: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastMessage: null,
      settings: RecentSettings(muteNotifications: false, autoDeleteMessages: 0),
    );

    debugPrint("createChat");

    return chat;
  }
}
