class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final String domainId;
  final DateTime createdAt;
  final List<GroupUser> users;
  final int version;
  final int memberCount;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.domainId,
    required this.createdAt,
    required this.users,
    required this.version,
    required this.memberCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['created_by'] ?? '',
      domainId: json['domain_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      users: (json['users'] as List<dynamic>?)
          ?.map((user) => GroupUser.fromJson(user))
          .toList() ?? [],
      version: json['__v'] ?? 0,
      memberCount: json['memberCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'created_by': createdBy,
      'domain_id': domainId,
      'created_at': createdAt.toIso8601String(),
      'users': users.map((user) => user.toJson()).toList(),
      '__v': version,
      'memberCount': memberCount,
      'id': id,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? domainId,
    DateTime? createdAt,
    List<GroupUser>? users,
    int? version,
    int? memberCount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      domainId: domainId ?? this.domainId,
      createdAt: createdAt ?? this.createdAt,
      users: users ?? this.users,
      version: version ?? this.version,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupModel &&
        other.id == id &&
        other.name == name &&
        other.createdBy == createdBy &&
        other.domainId == domainId &&
        other.createdAt == createdAt &&
        other.users == users &&
        other.version == version &&
        other.memberCount == memberCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        createdBy.hashCode ^
        domainId.hashCode ^
        createdAt.hashCode ^
        users.hashCode ^
        version.hashCode ^
        memberCount.hashCode;
  }

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, createdBy: $createdBy, domainId: $domainId, createdAt: $createdAt, users: $users, version: $version, memberCount: $memberCount)';
  }
}

class GroupUser {
  final UserSettings settings;
  final String userId;
  final String role;
  final DateTime joinedAt;

  GroupUser({
    required this.settings,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
      settings: UserSettings.fromJson(json['settings'] ?? {}),
      userId: json['user'] ?? '',
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      'user': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  GroupUser copyWith({
    UserSettings? settings,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupUser(
      settings: settings ?? this.settings,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupUser &&
        other.settings == settings &&
        other.userId == userId &&
        other.role == role &&
        other.joinedAt == joinedAt;
  }

  @override
  int get hashCode {
    return settings.hashCode ^
        userId.hashCode ^
        role.hashCode ^
        joinedAt.hashCode;
  }

  @override
  String toString() {
    return 'GroupUser(settings: $settings, userId: $userId, role: $role, joinedAt: $joinedAt)';
  }
}

class UserSettings {
  final String talkPriority;
  final bool canDisconnectFromGroup;
  final bool canSendAlertToGroup;
  final bool gpsLocation;

  UserSettings({
    required this.talkPriority,
    required this.canDisconnectFromGroup,
    required this.canSendAlertToGroup,
    required this.gpsLocation,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      talkPriority: json['talk_priority'] ?? 'normal',
      canDisconnectFromGroup: json['can_disconnect_from_group'] ?? true,
      canSendAlertToGroup: json['can_send_alert_to_group'] ?? true,
      gpsLocation: json['gps_location'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'talk_priority': talkPriority,
      'can_disconnect_from_group': canDisconnectFromGroup,
      'can_send_alert_to_group': canSendAlertToGroup,
      'gps_location': gpsLocation,
    };
  }

  UserSettings copyWith({
    String? talkPriority,
    bool? canDisconnectFromGroup,
    bool? canSendAlertToGroup,
    bool? gpsLocation,
  }) {
    return UserSettings(
      talkPriority: talkPriority ?? this.talkPriority,
      canDisconnectFromGroup: canDisconnectFromGroup ?? this.canDisconnectFromGroup,
      canSendAlertToGroup: canSendAlertToGroup ?? this.canSendAlertToGroup,
      gpsLocation: gpsLocation ?? this.gpsLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.talkPriority == talkPriority &&
        other.canDisconnectFromGroup == canDisconnectFromGroup &&
        other.canSendAlertToGroup == canSendAlertToGroup &&
        other.gpsLocation == gpsLocation;
  }

  @override
  int get hashCode {
    return talkPriority.hashCode ^
        canDisconnectFromGroup.hashCode ^
        canSendAlertToGroup.hashCode ^
        gpsLocation.hashCode;
  }

  @override
  String toString() {
    return 'UserSettings(talkPriority: $talkPriority, canDisconnectFromGroup: $canDisconnectFromGroup, canSendAlertToGroup: $canSendAlertToGroup, gpsLocation: $gpsLocation)';
  }
}

// Enum for talk priority levels
enum TalkPriority {
  low('low'),
  normal('normal'),
  high('high'),
  emergency('emergency');

  const TalkPriority(this.value);
  final String value;

  static TalkPriority fromString(String value) {
    return TalkPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TalkPriority.normal,
    );
  }
}

// Enum for user roles in group
enum GroupRole {
  admin('admin'),
  moderator('moderator'),
  member('member'),
  guest('guest');

  const GroupRole(this.value);
  final String value;

  static GroupRole fromString(String value) {
    return GroupRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => GroupRole.member,
    );
  }
}
