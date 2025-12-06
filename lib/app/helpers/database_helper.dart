import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Stream controller for database changes
  final _dbChangeController = StreamController<String>.broadcast();
  Stream<String> get onDatabaseChanged => _dbChangeController.stream;

  void notifyTableChanged(String table) {
    _dbChangeController.add(table);
  }

  // Get Database Instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('talkliner-client.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = appDocDir.path;
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
    );
  }

  // Create Database
  Future<void> _createDB(Database db, int version) async {
    // Chats Table
    await db.execute('''
      CREATE TABLE chats (
          id TEXT PRIMARY KEY,
          domain_id TEXT NOT NULL,
          chat_type TEXT NOT NULL,
          name TEXT,
          description TEXT,
          avatar TEXT,
          unread_count INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_by TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          settings TEXT NOT NULL
      )
    ''');

    // Users Table
    await db.execute('''
      CREATE TABLE users (
          id TEXT PRIMARY KEY,
          domain_id TEXT NOT NULL,
          username TEXT NOT NULL,
          display_name TEXT NOT NULL,
          settings TEXT,
          is_online INTEGER NOT NULL DEFAULT 0,
          status TEXT,
          fcm_token TEXT,
          apn_token TEXT,
          chat_id TEXT,
          profile_picture TEXT
      )
    ''');

    // Messages Table
    await db.execute('''
      CREATE TABLE messages (
          id TEXT PRIMARY KEY,
          chat_id TEXT NOT NULL,
          sender_id TEXT NOT NULL,
          content TEXT NOT NULL,
          message_type TEXT NOT NULL,
          file_url TEXT,
          file_name TEXT,
          file_size INTEGER,
          timestamp TEXT NOT NULL,
          edited INTEGER DEFAULT 0,
          edited_at TEXT,
          reply_to TEXT,
          is_me INTEGER DEFAULT 0,
          FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE,
          FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Participants Table
    await db.execute('''
      CREATE TABLE participants (
          id TEXT PRIMARY KEY,
          chat_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          role TEXT NOT NULL,
          joined_at TEXT NOT NULL,
          last_seen TEXT NOT NULL,
          FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // Empty All Tables
  Future<void> emptyAllTables() async {
    final db = await database;

    await db.rawQuery('DELETE FROM messages');
    await db.rawQuery('DELETE FROM participants');
    await db.rawQuery('DELETE FROM chats');
    await db.rawQuery('DELETE FROM users');
    debugPrint("Database Cleaned");
  }

  Future<void> deleteDatabase(String path) async {
    await databaseFactory.deleteDatabase(path);
    _database = await _initDB(path);
  }

  // Start Query Builder
  QueryBuilder table(String table) {
    return QueryBuilder(table, this);
  }

  // Helper to sanitize data (convert bool to int)
  // Convert object to json_encode
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is bool) {
        return MapEntry(key, value ? 1 : 0);
      }
      if (value is Map) {
        return MapEntry(key, jsonEncode(value));
      }
      return MapEntry(key, value);
    });
  }

  // Raw Insert (kept for compatibility or direct use)
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    var res = await db.insert(
      table,
      _sanitizeData(values),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyTableChanged(table);
    return res;
  }
}

class QueryBuilder {
  final String _table;
  final DatabaseHelper _dbHelper;

  List<String> _selects = ['*'];
  final List<String> _whereClauses = [];
  final List<dynamic> _whereArgs = [];
  String? _orderBy;
  String? _groupBy;
  int? _limit;
  int? _offset;
  bool _distinct = false;

  QueryBuilder(this._table, this._dbHelper);

  // Select columns
  QueryBuilder select(String columns) {
    if (columns != '*') {
      _selects = columns.split(',').map((e) => e.trim()).toList();
    }
    return this;
  }

  // Distinct
  QueryBuilder distinct([bool distinct = true]) {
    _distinct = distinct;
    return this;
  }

  // Group By
  QueryBuilder groupBy(String groupBy) {
    _groupBy = groupBy;
    return this;
  }

  // Where clause
  // Usage: .where('id', 1) or .where('age >', 18)
  QueryBuilder where(String field, dynamic value) {
    if (field.contains(' ')) {
      // e.g. 'age >'
      _whereClauses.add('$field ?');
    } else {
      // e.g. 'id'
      _whereClauses.add('$field = ?');
    }
    _whereArgs.add(value);
    return this;
  }

  // Order By
  QueryBuilder orderBy(String field, [String direction = 'ASC']) {
    _orderBy = '$field $direction';
    return this;
  }

  // Limit and Offset
  QueryBuilder limit(int limit, [int? offset]) {
    _limit = limit;
    _offset = offset;
    return this;
  }

  // Get results
  Future<List<Map<String, dynamic>>> get() async {
    final db = await _dbHelper.database;
    return await db.query(
      _table,
      distinct: _distinct,
      columns: _selects.contains('*') ? null : _selects,
      where: _whereClauses.isNotEmpty ? _whereClauses.join(' AND ') : null,
      whereArgs: _whereArgs.isNotEmpty ? _whereArgs : null,
      groupBy: _groupBy,
      orderBy: _orderBy,
      limit: _limit,
      offset: _offset,
    );
  }

  // Get single row
  Future<Map<String, dynamic>?> getRow() async {
    limit(1);
    final results = await get();
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Insert
  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    var res = await db.insert(
      _table,
      _dbHelper._sanitizeData(data),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _dbHelper.notifyTableChanged(_table);
    return res;
  }

  // Insert Batch
  Future<void> insertBatch(List<Map<String, dynamic>> dataList) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var data in dataList) {
        batch.insert(
          _table,
          _dbHelper._sanitizeData(data),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    _dbHelper.notifyTableChanged(_table);
  }

  // Update
  Future<int> update(Map<String, dynamic> data) async {
    final db = await _dbHelper.database;
    var res = await db.update(
      _table,
      _dbHelper._sanitizeData(data),
      where: _whereClauses.isNotEmpty ? _whereClauses.join(' AND ') : null,
      whereArgs: _whereArgs.isNotEmpty ? _whereArgs : null,
    );
    _dbHelper.notifyTableChanged(_table);
    return res;
  }

  // Delete
  Future<int> delete() async {
    final db = await _dbHelper.database;
    var res = await db.delete(
      _table,
      where: _whereClauses.isNotEmpty ? _whereClauses.join(' AND ') : null,
      whereArgs: _whereArgs.isNotEmpty ? _whereArgs : null,
    );
    _dbHelper.notifyTableChanged(_table);
    return res;
  }

  // Count
  Future<int> count() async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
          await db.query(
            _table,
            columns: ['COUNT(*)'],
            where:
                _whereClauses.isNotEmpty ? _whereClauses.join(' AND ') : null,
            whereArgs: _whereArgs.isNotEmpty ? _whereArgs : null,
          ),
        ) ??
        0;
  }
}

/*
Examples:

// 1. Get all chats
var chats = await DatabaseHelper().table('chats').get();

// 2. Get specific chat by ID
var chat = await DatabaseHelper().table('chats').where('id', '123').getRow();

// 3. Insert a new user
await DatabaseHelper().table('users').insert({
  'id': 'user_001',
  'username': 'john_doe',
  'display_name': 'John Doe',
});

// 4. Update a chat's unread count
await DatabaseHelper().table('chats')
  .where('id', 'chat_001')
  .update({'unread_count': 5});

// 5. Delete a participant
await DatabaseHelper().table('participants')
  .where('chat_id', 'chat_001')
  .where('user_id', 'user_001')
  .delete();

// 6. Complex Select with Order and Limit
var messages = await DatabaseHelper().table('messages')
  .select('id, content, timestamp')
  .where('chat_id', 'chat_001')
  .orderBy('timestamp', 'DESC')
  .limit(20)
  .get();

// 7. Count messages in a chat
int count = await DatabaseHelper().table('messages')
  .where('chat_id', 'chat_001')
  .count();

// 8. Insert multiple records (Batch)
await DatabaseHelper().table('users').insertBatch([
  {'id': 'user_002', 'username': 'jane_doe', 'display_name': 'Jane Doe'},
  {'id': 'user_003', 'username': 'bob_smith', 'display_name': 'Bob Smith'},
]);

*/
