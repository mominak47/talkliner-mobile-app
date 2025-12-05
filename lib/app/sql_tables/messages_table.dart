import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/helpers/database_helper.dart';
import 'package:talkliner/app/sql_tables/users_table.dart';

class MessagesTable {
  static const String tableName = 'messages';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Contructor
  MessagesTable() {
    dbHelper.database;
  }

  getMessages(String chatId, int perPage) async {
    var sql = """
SELECT 
    messages.id,
    messages.chat_id,
    messages.sender_id,
    messages.content,
    messages.message_type,
    messages.file_url,
    messages.is_me,
    messages.timestamp,
    messages.edited,
    messages.edited_at,
    messages.reply_to,
    users.display_name,
    users.profile_picture
FROM 
    messages
LEFT JOIN 
    users ON messages.sender_id = users.id
WHERE 
    messages.chat_id = '$chatId'
ORDER BY 
    messages.timestamp DESC
LIMIT 
    $perPage
    """;

    var db = await DatabaseHelper().database;

    var messages = await db.rawQuery(sql);

    var newMessages =
        messages.map((e) => Map<String, dynamic>.from(e)).toList();

    return newMessages;
    // var messages =
    //     await dbHelper
    //         .table(tableName)
    //         .where('chat_id', chatId)
    //         .orderBy('timestamp', 'desc')
    //         .limit(perPage)
    //         .groupBy('id')
    //         .get();

    // var newMessages =
    //     messages.map((e) => Map<String, dynamic>.from(e)).toList();

    // var participants = await ChatTable().getChatParticipants(chatId);

    // for (var message in newMessages) {
    //   message['edited'] = message['edited'] == 1 ? true : false;
    // }

    // return newMessages;
  }

  getMessage(String id) async {
    var user = await dbHelper.table(tableName).where('id', id).get();
    if (user.isNotEmpty) {
      // Mutable User
      var mutableUser = Map<String, dynamic>.from(user[0]);
      mutableUser['settings'] = jsonDecode(mutableUser['settings']);

      return mutableUser;
    }
    return null;
  }

  format(MessageModel message, String chatId) {
    return {
      'id': message.id,
      'chat_id': chatId,
      'sender_id': message.senderId,
      'content': message.content,
      'message_type': message.messageType,
      'file_url': message.fileUrl,
      'is_me': message.isMe,
      'timestamp': message.timestamp.toIso8601String(),
      'edited': message.edited,
      'edited_at': message.editedAt?.toIso8601String(),
      'reply_to': message.replyTo,
    };
  }

  insert(MessageModel message, String chatId) async {
    // Check if chat already exists
    final result =
        await dbHelper.table(tableName).where('id', message.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Message : id = ${message.id}");
      return update(message, chatId);
    } else {
      debugPrint("[SQL] INSERT Message : id = ${message.id}");
      // Insert
      return dbHelper.insert(tableName, format(message, chatId));
    }
  }

  update(MessageModel message, String chatId) async {
    // Check if chat already exists
    final result =
        await dbHelper.table(tableName).where('id', message.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Message : id = ${message.id}");
      var insertObject = format(message, chatId);
      insertObject.remove('id');

      // Update`
      return dbHelper
          .table(tableName)
          .where('id', message.id)
          .update(insertObject);
    }
  }

  insertBatch(List<MessageModel> messages, String chatId) async {
    List<Map<String, dynamic>> dataList = [];
    for (var message in messages) {
      dataList.add(format(message, chatId));
    }
    return dbHelper.table(tableName).insertBatch(dataList);
  }
}
