import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/models/recent_item.dart';
import 'package:talkliner/app/services/api_service.dart';

class RecentsController extends GetxController {
  final ApiService apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxList<RecentItem> recents = <RecentItem>[].obs;

  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    apiService.onInit();
    getInfoFromLocalStorage();
    // Use WidgetsBinding to ensure this runs after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchRecents();
    });
  }

  Future<void> fetchRecents({bool shouldShowLoading = false}) async {
    if (shouldShowLoading) {
      isLoading.value = true;
    }
    final response = await apiService.get('/chats');
    try {
      if (response.statusCode == 200) {
        final List<dynamic> recentList = response.body['data']['chats'] ?? [];
        recents.assignAll(
          recentList.map((recent) => RecentItem.fromJson(recent)).toList(),
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
    _storage.write('recents', recents.map((recent) => recent.toJson()).toList());
  }

  void getInfoFromLocalStorage() {
    final recentList = _storage.read('recents') ?? [];
    recents.assignAll(
      (recentList as List<dynamic>)
          .map((recent) => RecentItem.fromJson(recent))
          .toList(),
    );
  }
}
