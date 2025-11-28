import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';
import 'package:talkliner/app/models/group_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class ContactsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final refreshGroupsIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final RxList<UserModel> contacts = <UserModel>[].obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final ApiService apiService = ApiService();

  final RxString searchQuery = "".obs;

  // Tab bar index
  final RxString selectedTabBar = "users".obs;

  late TabController tabController;

  // Worker
  Worker? _tabsWorker;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    apiService.onInit();
    fetchContacts();
    fetchGroups();
    loadingContacts();
    loadingGroups();

    _tabsWorker = ever(selectedTabBar, (_) {
      if (selectedTabBar.value == "users") {
        fetchContacts();
      } else {
        fetchGroups();
      }
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    _tabsWorker?.dispose();
    super.onClose();
  }

  String getSelectedTabBar() => selectedTabBar.value;

  void searchContact(String query) => searchQuery.value = query;

  void clearSearch() => searchQuery.value = "";

  void changeTabBar(String tabBar) => selectedTabBar.value = tabBar;

  void loadContacts() => contacts.assignAll(contacts);

  void loadingContacts() => WidgetsBinding.instance.addPostFrameCallback(
    (_) => refreshIndicatorKey.currentState?.show(),
  );

  void loadingGroups() => WidgetsBinding.instance.addPostFrameCallback(
    (_) => refreshGroupsIndicatorKey.currentState?.show(),
  );

  // Fetch contacts from the API
  Future<void> fetchContacts() async {
    try {
      final response = await apiService.makeGetRequest('/domains/contacts');
      if (response.body['success'] == true) {
        debugPrint(
          "fetchContacts: ${response.body['data']['contacts'][0].toString()}",
        );
        final List<dynamic> contactList =
            response.body['data']['contacts'] ?? [];
        contacts.assignAll(
          contactList.map((contact) => UserModel.fromJson(contact)).toList(),
        );
      } else {
        debugPrint(response.body['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      // There is no 'hide' method for RefreshIndicatorState.
      // To hide the indicator, complete the Future returned by onRefresh.
      // So, nothing to do here. The UI will handle hiding after Future completes.
    }
  }

  Future<void> fetchGroups() async {
    final response = await apiService.makeGetRequest(
      '/domains/contacts/groups',
    );

    if (response.statusCode == 200) {
      // Print Token
      final token = await TokenManager.getToken();
      debugPrint("Token: ${token.toJson()}");
      final List<dynamic> groupList = response.body['data']['groups'] ?? [];
      groups.assignAll(
        groupList.map((group) => GroupModel.fromJson(group)).toList(),
      );
      debugPrint("fetchGroups: ${response.body['data']['groups'].toString()}");
      // saveInfoInLocalStorage();
    } else {
      debugPrint(response.body.toString());
    }
  }

  Future<void> refreshContacts() async => await fetchContacts();

  Future<void> refreshGroups() async => await fetchGroups();
}
