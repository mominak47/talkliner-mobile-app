import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class RecentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxList<ChatModel> recents = <ChatModel>[].obs;

  final GetStorage _storage = GetStorage();

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    apiService.onInit();
    getInfoFromLocalStorage();
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
      recents.where((r) => r.chatType != 'group').toList();

  List<ChatModel> get groupRecents =>
      recents.where((r) => r.chatType == 'group').toList();

  Future<void> fetchRecents({bool shouldShowLoading = false}) async {
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

  void saveInfoInLocalStorage() {
    _storage.write(
      'recents',
      recents.map((recent) => recent.toJson()).toList(),
    );
  }

  void getInfoFromLocalStorage() {
    final recentList = _storage.read('recents') ?? [];
    recents.assignAll(
      (recentList as List<dynamic>)
          .map((recent) => ChatModel.fromJson(recent))
          .toList(),
    );
  }
}
