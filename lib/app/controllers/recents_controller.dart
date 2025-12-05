import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/cachemanagers/chat_cache.dart';
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

  final GetStorage _storage = GetStorage('chat_cache');

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
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  List<ChatModel> get userRecents =>
      recents.where((r) => r.chatType != ChatType.group).toList();

  List<ChatModel> get groupRecents =>
      recents.where((r) => r.chatType == ChatType.group).toList();

  Future<void> fetchRecents({bool shouldShowLoading = false}) async {
    if (shouldShowLoading) isLoading.value = true;

    final response = await apiService.get('/chats');
    try {
      if (response.statusCode == 200) {
        final List<dynamic> recentList = response.body['data']['chats'] ?? [];
        final List<ChatModel> recentModels =
            recentList.map((recent) => ChatModel.fromJson(recent)).toList();
        // recents.assignAll(recentModels);
        saveInfoInLocalStorage(recentModels);
        getChatsFromDatabase();
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
