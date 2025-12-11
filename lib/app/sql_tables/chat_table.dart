import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:talkliner/app/debugging/ansicolor.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/helpers/database_helper.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';
import 'package:talkliner/app/sql_tables/participants_table.dart';
import 'package:talkliner/app/sql_tables/users_table.dart';

class ChatTable {
  static const String tableName = 'chats';
  final DatabaseHelper dbHelper = DatabaseHelper();
  // Contructor
  ChatTable();

  format(ChatModel chat) {
    return {
      'id': chat.id,
      'domain_id': chat.domainId,
      'chat_type': chat.chatType.name,
      'name': chat.name,
      'description': chat.description,
      'avatar': chat.avatar,
      'unread_count': chat.unreadCount,
      'is_active': chat.isActive,
      'created_by': chat.createdBy,
      'created_at': chat.createdAt.toIso8601String(),
      'updated_at': chat.updatedAt.toIso8601String(),
      'settings': chat.settings.toJson().toString(),
    };
  }

  getChatById(String id) async {
    final db = await dbHelper.database;
    // Make a join SQL code for chats and participants
    final _sql = "SELECT * FROM chats WHERE id = '$id'";
    var results = await db.rawQuery(_sql);
    // Create mutable copy
    var chats = results.map((e) => Map<String, dynamic>.from(e)).toList();

    List<ChatModel> _chats = await _processChats(chats);

    return _chats.isNotEmpty ? _chats.first : null;
  }

  Future<List<ChatModel>> _processChats(
    List<Map<String, dynamic>> chats,
  ) async {
    for (var chat in chats) {
      var participants = await ParticipantsTable().getParticipants(chat['id']);
      chat['participants'] = participants;
      chat['messages'] = await MessagesTable().getMessages(chat['id'], 10);
    }

    var mutableChats =
        chats.map((item) {
          // var messages = await MessagesTable().getMessages(item['id'], 10);
          return ChatModel.fromJson({
            'id': item['id'],
            'domain_id': item['domain_id'],
            'chat_type': item['chat_type'],
            'participants': item['participants'],
            'name': item['name'],
            'description': item['description'],
            'avatar': item['avatar'],
            'unread_count': item['unread_count'],
            'is_active': item['is_active'] == 1,
            'created_by': item['created_by'],
            'createdAt': item['created_at'],
            'updatedAt': item['updated_at'],
            'settings': {
              'mute_notifications': false,
              'auto_delete_messages': 0,
            },
            'messages': item['messages'],
          });
        }).toList();

    return mutableChats;
  }

  getChats() async {
    final db = await dbHelper.database;
    // Make a join SQL code for chats and participants
    final _sql = "SELECT * FROM chats";
    var results = await db.rawQuery(_sql);
    // Create mutable copy
    var chats = results.map((e) => Map<String, dynamic>.from(e)).toList();

    return _processChats(chats);
  }

  getChatParticipants(String chatId) async {
    final db = await dbHelper.database;
    // Make a join SQL code for chats and participants
    final _sql = "SELECT * FROM participants WHERE chat_id = '$chatId'";
    var results = await db.rawQuery(_sql);
    // Create mutable copy
    var participants = results.map((e) => e['user_id'] as String).toList();

    var users = await UsersTable().getUsersByIds(participants);

    var mutableUsers = users.map((e) => UserModel.fromJson(e)).toList();

    return mutableUsers.isNotEmpty ? mutableUsers : null;
  }

  insert(ChatModel chat) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', chat.id).get();
    if (result.isNotEmpty) {
      debugPrint(sql("[SQL] UPDATE Chat : id = ${chat.id}"));
      return update(chat);
    } else {
      debugPrint(sql("[SQL] INSERT Chat : id = ${chat.id}"));
      return dbHelper.insert(tableName, format(chat));
    }
  }

  update(ChatModel chat) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', chat.id).get();
    if (result.isNotEmpty) {
      debugPrint(sql("[SQL] UPDATE Chat : id = ${chat.id}"));

      // Insert Users
      update_users(chat);
      // Insert Participants
      update_participants(chat);
      // // Insert Messages
      update_messages(chat, chat.id);
      // // Update Chat

      var insertObject = format(chat);
      insertObject.remove('id');
      // Update`
      return dbHelper
          .table(tableName)
          .where('id', chat.id)
          .update(insertObject);
    }
  }

  update_users(ChatModel chat) async {
    var users = chat.participants.map((p) => p.user);
    // Loop
    for (var user in users) {
      if (user != null) UsersTable().insert(user);
    }
  }

  update_participants(ChatModel chat) async {
    var participants = chat.participants;
    // Loop
    for (var participant in participants) {
      if (participant != null) {
        ParticipantsTable().insert(participant, chat.id);
      }
    }
  }

  update_messages(ChatModel chat, String chatId) async {
    var messages = chat.messages;
    // Loop
    if (messages != null && messages.isNotEmpty) {
      for (var message in messages) {
        MessagesTable().insert(message, chatId);
      }
    }
  }

  insertBatch(List<ChatModel> chats) async {
    List<Map<String, dynamic>> dataList = [];
    print(warn("[SQL] INSERT Batch Chat : ${chats.length}"));
    for (var chat in chats) {
      dataList.add(format(chat));
    }
    return dbHelper.table(tableName).insertBatch(dataList);
  }
}
