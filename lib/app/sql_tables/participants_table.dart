import 'package:flutter/rendering.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/sql_tables/database_helper.dart';
import 'package:talkliner/app/sql_tables/users_table.dart';

class ParticipantsTable {
  static const String tableName = 'participants';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Contructor
  ParticipantsTable() {
    dbHelper.database;
  }

  getParticipants(String chatID) async {
    var participants =
        await dbHelper.table(tableName).where('chat_id', chatID).get();
    var mutableParticipants =
        participants.map((e) => Map<String, dynamic>.from(e)).toList();

    for (var participant in mutableParticipants) {
      var user = await UsersTable().getUser(participant['user_id']);
      participant['user'] = user;
      participant['user_id'] = {
        '_id': user['id'],
        'id': user['id'],
        'username': user['username'],
        'display_name': user['display_name'],
      };
    }

    return mutableParticipants;
  }

  format(RecentParticipant participant, String chatID) {
    return {
      'id': participant.id,
      'user_id': participant.user?.id,
      'chat_id': chatID,
      'role': participant.role.name,
      'joined_at': participant.joinedAt.toIso8601String(),
      'last_seen': participant.lastSeen.toIso8601String(),
    };
  }

  insert(RecentParticipant participant, String chatID) async {
    // Check if chat already exists
    final result =
        await dbHelper
            .table(tableName)
            .where('user_id', participant.user?.id)
            .where('chat_id', chatID)
            .get();

    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Participant : id = ${participant.user?.id}");
      return update(participant, chatID);
    } else {
      debugPrint("[SQL] INSERT User : id = ${participant.user?.id}");
      // Insert
      return dbHelper.insert(tableName, format(participant, chatID));
    }
  }

  update(RecentParticipant participant, String chatID) async {
    // Check if chat already exists
    final result =
        await dbHelper
            .table(tableName)
            .where('user_id', participant.user?.id)
            .where('chat_id', chatID)
            .get();
    if (result.isNotEmpty) {
      debugPrint("[SQL] UPDATE Participant : id = ${participant.user?.id}");
      var insertObject = format(participant, chatID);
      insertObject.remove('id');

      // Update
      return dbHelper
          .table(tableName)
          .where('user_id', participant.user?.id)
          .where('chat_id', chatID)
          .update(insertObject);
    }
  }
}
