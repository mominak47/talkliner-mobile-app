import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/services/talkliner_service.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/helpers/database_helper.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class RecentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxList<ChatModel> recents = <ChatModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    apiService.onInit();
    getChatsFromDatabase();
    // Use WidgetsBinding to ensure this runs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecents();
    });

    // Listen to database changes
    DatabaseHelper().onDatabaseChanged.listen((table) {
      if (['chats', 'messages', 'users', 'participants'].contains(table)) {
        getChatsFromDatabase();
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
    }
  }

  void search(String query) {
    searchQuery.value = query;
  }

  List<ChatModel> get filteredRecents {
    if (searchQuery.value.isEmpty) return recents;
    return recents.where((chat) {
      final name = chat.name?.toLowerCase() ?? '';
      final otherName =
          chat.participants.isNotEmpty
              ? chat.participants[0].userId.displayName.toLowerCase()
              : '';
      final query = searchQuery.value.toLowerCase();
      return name.contains(query) || otherName.contains(query);
    }).toList();
  }

  List<ChatModel> get userRecents =>
      filteredRecents.where((r) => r.chatType != ChatType.group).toList();

  List<ChatModel> get groupRecents =>
      filteredRecents.where((r) => r.chatType == ChatType.group).toList();

  Future<void> fetchRecents({bool shouldShowLoading = false}) async {
    if (shouldShowLoading) isLoading.value = true;
    try {
      final response = await TalklinerService.get('/chats');
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        final List<dynamic> recentList = body['data']['chats'] ?? [];

        final List<ChatModel> recentModels =
            recentList.map((recent) => ChatModel.fromJson(recent)).toList();
        saveInfoInLocalStorage(recentModels);
      } else {
        debugPrint(response.body.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (shouldShowLoading) isLoading.value = false;
    }
  }

  Future<void> refreshRecents() async => await fetchRecents();

  ChatModel? getChatByParticipant(UserModel participant) {
    return recents.firstWhereOrNull(
      (chat) => chat.participants.any((p) => p.userId.id == participant.id),
    );
  }

  ChatModel? getChatByChatId(String chatId) {
    return recents.firstWhereOrNull((chat) => chat.id == chatId);
  }

  void saveInfoInLocalStorage(List<ChatModel> recents) async {
    if (recents.isEmpty) return;
    debugPrint("Saving To Local Storage: ${recents.length} chats");

    for (var chat in recents) {
      await ChatTable().insert(chat);
    }
  }

  getChatsFromDatabase() async {
    debugPrint("WE ARE GETTING FROM CACHE");
    var chats = await ChatTable().getChats();
    debugPrint("⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️");
    debugPrint("➡️Loading From Cache ${chats.toString()}⬅️");
    debugPrint("⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️");
    if (chats != null && chats.isNotEmpty) recents.assignAll(chats);
  }
}
