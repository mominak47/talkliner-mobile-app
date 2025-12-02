import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:talkliner/app/sql_tables/database_helper.dart';
import 'package:talkliner/app/models/chat_model.dart';

class ChatTable {
  static const String tableName = 'chats';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Contructor
  ChatTable() {
    dbHelper.database;
  }

  format(ChatModel chat) {
    return {
      'id': chat.id,
      'domain_id': chat.domainId,
      'chat_type': chat.chatType.toString(),
      'name': chat.name,
      'description': chat.description,
      'avatar': chat.avatar,
      'unread_count': chat.unreadCount,
      'is_active': chat.isActive,
      'created_by': chat.createdBy,
      'created_at': chat.createdAt.toIso8601String(),
      'updated_at': chat.updatedAt.toIso8601String(),
      'mute_notifications': chat.settings.muteNotifications,
      'auto_delete_messages': chat.settings.autoDeleteMessages,
    };
  }

  insert(ChatModel chat) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', chat.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Chat : id = ${chat.id}");
      return update(chat);
    } else {
      debugPrint("[SQL] INSERT Chat : id = ${chat.id}");
      // Insert
      return dbHelper.insert(tableName, format(chat));
    }
  }

  update(ChatModel chat) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', chat.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Chat : id = ${chat.id}");
      var insertObject = format(chat);
      insertObject.remove('id');
      // Update`
      return dbHelper
          .table(tableName)
          .where('id', chat.id)
          .update(insertObject);
    }
  }

  insertBatch(List<ChatModel> chats) async {
    List<Map<String, dynamic>> dataList = [];
    for (var chat in chats) {
      dataList.add(format(chat));
    }
    return dbHelper.table(tableName).insertBatch(dataList);
  }
}
