import 'package:get/get.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/user_model.dart';

class UserEventsController {
  final SocketController socketController = Get.find<SocketController>();
  // List of usersmodel
  final List<UserModel> users = [];

  void onEventFor(String userId, Function callback) {
    // Listen to socket events
    socketController.on('USER_TO_USER_EVENT', (data) {
      if(data['user_id'] == userId) {
          callback(data);
      }
    });
  }

  void addUser(UserModel user) {
    users.add(user);
  }

  void removeUser(UserModel user) {
    users.remove(user);
  }

  UserModel getUser(String userId) {
    return users.firstWhere((user) => user.id == userId);
  }

  List<UserModel> getUsers() {
    return users;
  }
}