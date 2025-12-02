import 'package:flutter/rendering.dart';
import 'package:talkliner/app/sql_tables/database_helper.dart';
import 'package:talkliner/app/models/user_model.dart';

class ChatTable {
  static const String tableName = 'users';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Contructor
  ChatTable() {
    dbHelper.database;
  }

  format(UserModel user) {
    return {
      'id': user.id,
      'domain_id': user.domainId,
      'username': user.username,
      'display_name': user.displayName,
      'settings': user.settings.toJson().toString(),
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
      debugPrint("[SQL] UPDATE Chat : id = ${user.id}");
      return update(user);
    } else {
      debugPrint("[SQL] INSERT Chat : id = ${user.id}");
      // Insert
      return dbHelper.insert(tableName, format(user));
    }
  }

  update(UserModel user) async {
    // Check if chat already exists
    final result = await dbHelper.table(tableName).where('id', user.id).get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Chat : id = ${user.id}");
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
