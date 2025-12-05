import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:talkliner/app/helpers/database_helper.dart';
import 'package:talkliner/app/models/user_model.dart';

class UsersTable {
  static const String tableName = 'users';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Contructor
  UsersTable() {
    dbHelper.database;
  }

  getUser(String id) async {
    var user = await dbHelper.table(tableName).where('id', id).get();
    if (user.isNotEmpty) {
      // Mutable User
      var mutableUser = Map<String, dynamic>.from(user[0]);
      mutableUser['id'] = id;
      mutableUser['settings'] = jsonDecode(mutableUser['settings']);

      return mutableUser;
    }
    return null;
  }

  getUsersByIds(List<String> ids) async {
    var users = [];

    for (var id in ids) {
      var user = await getUser(id);
      if (user != null) {
        users.add(user);
      }
    }

    return users;
  }

  format(UserModel user) {
    return {
      'id': user.id,
      'domain_id': user.domainId,
      'username': user.username,
      'display_name': user.displayName,
      'settings': user.settings.toJson(),
      'is_online': user.isOnline,
      'status': user.status,
      'fcm_token': user.fcmToken,
      'apn_token': user.apnToken,
      'chat_id': user.chatId,
      'profile_picture': user.profilePicture,
    };
  }

  insert(UserModel user) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', user.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE User : id = ${user.id}");
      return update(user);
    } else {
      debugPrint("[SQL] INSERT User : id = ${user.id}");
      // Insert
      return dbHelper.insert(tableName, format(user));
    }
  }

  update(UserModel user) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', user.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE User : id = ${user.id}");
      var insertObject = format(user);
      insertObject.remove('id');

      // Update`
      return dbHelper
          .table(tableName)
          .where('id', user.id)
          .update(insertObject);
    }
  }

  insertBatch(List<UserModel> users) async {
    List<Map<String, dynamic>> dataList = [];
    for (var user in users) {
      dataList.add(format(user));
    }
    return dbHelper.table(tableName).insertBatch(dataList);
  }
}
