import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/battery_service.dart';
import 'package:talkliner/app/services/chat_service.dart';
import 'package:talkliner/app/services/fcm_service.dart';
import 'package:talkliner/app/services/network_service.dart';

enum SocketConnectionQuality {
  excellent, // < 50ms
  good, // 50-100ms
  fair, // 100-200ms
  poor, // 200-500ms
  veryPoor, // > 500ms
  disconnected, // -1
}

class SocketController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxBool isConnected = false.obs;
  io.Socket? _socket;
  RxString event = ''.obs;
  RxMap<String, dynamic> eventData = <String, dynamic>{}.obs;
  RxDouble latency = 0.0.obs;
  Rx<SocketConnectionQuality> connectionQuality =
      SocketConnectionQuality.disconnected.obs;

  @override
  void onInit() {
    super.onInit();
    authController.isLoggedIn.listen((value) async {
      if (value && !isConnected.value) {
        await connect();
      } else {
        await disconnect();
      }
    });

    isConnected.listen((isConnected) => sendPing());
    latency.listen((latency) => updateConnectionQuality());

    connect();
  }

  void updateConnectionQuality() {
    if (latency.value < 50) {
      connectionQuality.value = SocketConnectionQuality.excellent;
    } else if (latency.value < 100) {
      connectionQuality.value = SocketConnectionQuality.good;
    } else if (latency.value < 200) {
      connectionQuality.value = SocketConnectionQuality.fair;
    } else if (latency.value < 500) {
      connectionQuality.value = SocketConnectionQuality.poor;
    } else {
      connectionQuality.value = SocketConnectionQuality.veryPoor;
    }
  }

  Map<String, dynamic> _getSocketOptions() {
    return io.OptionBuilder()
        .setPath("/ws")
        .setTransports(['websocket', 'polling']) // Add polling as fallback
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setTimeout(20000) // 20 second timeout
        .setAuth({'token': authController.token})
        .build();
  }

  Future<void> connect() async {
    debugPrint('SocketController: Connecting to socket');
    await disconnect();
    try {
      _socket = io.io(AppConfig.socketUrl, _getSocketOptions());
      // Connect to the server
      _socket!.connect();
      _setupSocketListeners();
    } catch (e) {
      debugPrint('SocketController: Error connecting to socket: $e');
    }
  }

  Future<void> disconnect() async {
    debugPrint('SocketController: Disconnecting socket');
    if (_socket != null) {
      debugPrint('SocketController: Disconnecting existing socket connection');
      _socket!.disconnect();
      _socket = null;
    }
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    _socket!.onConnect((data) {
      event.value = 'connected';
      debugPrint('SocketController: Connected to socket');
      isConnected.value = true;
    });

    _socket!.onDisconnect((data) {
      event.value = 'disconnected';
      debugPrint('SocketController: Disconnected from socket');
      isConnected.value = false;
      connectionQuality.value = SocketConnectionQuality.disconnected;
    });

    _socket!.onError((error) {
      event.value = 'error';
      debugPrint('SocketController: Error on socket: $error');
      isConnected.value = false;
    });

    // On any event
    _socket!.onAny((event, data) {
      if (event == 'new_message') {
        ChatService.appendMessageToChat(data['chat_id'], MessageModel.fromJson(data['message']));
        eventData.value = data;
      }

      if(event == 'USER_TO_USER_EVENT') {
        eventData.value = data;
      }

      this.event.value = event;
    });

    _socket!.on('pong', onPong);
  }

  // Emit event
  void emit(String event, dynamic data) {
    _socket!.emit(event, data);
  }

  // On event
  void on(String event, Function(dynamic) callback) {
    _socket!.on(event, callback);
  }

  // Off event
  void off(String event) {
    _socket!.off(event);
  }

  // Ping

  void sendPing() async {
    if (_socket != null && _socket!.connected) {
      try {
        Map<String, dynamic> batteryInfo = BatteryService().getBatteryInfoMap();

        // Get location with timeout for iOS TestFlight
        // Position? location;
        // try {
        //   location = await LocationService().getCurrentPosition().timeout(
        //     Duration(seconds: 5),
        //     onTimeout: () {
        //       debugPrint('SocketService: Location timeout, using null');
        //       return null;
        //     },
        //   );
        // } catch (e) {
        //   debugPrint('SocketService: Error getting location: $e');
        // }

        // Get network type WIFI or MOBILE
        String networkType = NetworkService().getNetworkType();

        // Get FCM token with timeout
        String? fcmToken = "";
        // try {
        //   fcmToken = await FCMService.getToken();
        // } catch (e) {
        //   debugPrint('SocketService: Error getting FCM token: $e');
        // }

        Map<String, dynamic> pingData = {
          'time': DateTime.now().millisecondsSinceEpoch,
          'battery': batteryInfo,
          'location': null, //location?.toJson(),
          'networkType': networkType,
          'fcmToken': fcmToken,
          'voipToken': null, //VoipPushService().voipToken,
        };

        _socket!.emit('ping', pingData);
        
        // Send ping every 10 seconds
        Future.delayed(
          Duration(seconds: AppConfig.pingInterval),
          () => sendPing(),
        );
      } catch (e) {
        debugPrint('SocketService: Error sending ping: $e');
      }
    } else {
      debugPrint('SocketService: Cannot send ping - socket not connected');
    }
  }

  void onPong(dynamic data) {
    int time = data['data']['time'];
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    latency.value = (currentTime - time).toDouble();
  }

  void emitTo(UserModel user, String event, dynamic data) {
    // If sockets is connected
    if(_socket?.connected ?? false) {
      _socket!.emit('USER_TO_USER_EVENT', {
        'user_id': user.id,
        'event': event,
        'data': data,
      });
      debugPrint('SocketController: Emitted to user: $user, event: $event, data: $data');
    } else {
      debugPrint('SocketController: Cannot emit to user - socket not connected');
    }
  }
}
