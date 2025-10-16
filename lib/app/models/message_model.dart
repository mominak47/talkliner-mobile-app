import 'package:get/get.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String messageType;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime timestamp;
  final bool edited;
  final DateTime? editedAt;
  final String? replyTo;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.timestamp,
    required this.edited,
    this.editedAt,
    this.replyTo,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic senderField = json['sender_id'];
    final String parsedSenderId = senderField is Map<String, dynamic>
        ? senderField['_id'] as String
        : senderField as String;

    return MessageModel(
      id: json['_id'] as String,
      senderId: parsedSenderId,
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      edited: json['edited'] as bool,
      editedAt: json['edited_at'] != null
          ? DateTime.tryParse(json['edited_at'] as String)
          : null,
      replyTo: json['reply_to'] as String?,
      isMe: parsedSenderId == Get.find<AuthController>().user.value?.id,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'sender_id': senderId,
        'content': content,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'timestamp': timestamp.toIso8601String(),
        'edited': edited,
        'edited_at': editedAt?.toIso8601String(),
        'reply_to': replyTo,
        'is_me': isMe,
      };
}