import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/cachemanagers/chat_cache.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/sql_tables/database_helper.dart';
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
    getChatsFromCache();
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
    getChatsFromCache();

    if (shouldShowLoading) {
      isLoading.value = true;
    }

    final response = await apiService.get('/chats');
    try {
      if (response.statusCode == 200) {
        final List<dynamic> recentList = response.body['data']['chats'] ?? [];
        recents.assignAll(
          recentList.map((recent) => ChatModel.fromJson(recent)).toList(),
        );
        saveInfoInLocalStorage();
      } else {
        debugPrint(response.body.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (shouldShowLoading) {
        isLoading.value = false;
      }
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

  void saveInfoInLocalStorage() async {
    if (recents.isEmpty) return;
    debugPrint("Saving To Local Storage: ${recents.length} chats");

    await ChatTable().insertBatch(recents);
  }

  Future<int> getChatsFromCache() async {
    var chats = await DatabaseHelper().table('chats').get();

    debugPrint("Loading From Cache ${chats.toString()}");

    // final time = _storage.read('recents_chat_ids_time');

    // if (time == null) {
    //   return 0;
    // }

    // // If time is older than 1 minute
    // if (time <
    //     DateTime.now()
    //         .subtract(const Duration(minutes: 1))
    //         .millisecondsSinceEpoch) {
    //   return 0;
    // }

    // debugPrint("Loading From Cache");

    // final recentList = _storage.read('recents_chat_ids') ?? [];

    // List<ChatModel> chats = [];

    // recentList.forEach((chatId) {
    //   var chat = ChatCache().getChat(chatId);
    //   if (chat != null) {
    //     chats.add(chat);
    //   }
    // });

    // recents.assignAll(chats);
    // debugPrint("[RecentsController] : getChatsFromCache");

    return 0; //chats.length;
  }
}
