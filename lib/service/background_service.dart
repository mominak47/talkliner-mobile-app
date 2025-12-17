import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';
import 'package:talkliner/app/config/app_config.dart';

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // Initialize GetStorage for background isolate
  await GetStorage.init();
  await GetStorage.init("user_cache");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Check for auth token
  final token = await TokenManager.getToken();
  if (!token.isValid) {
    debugPrint('[BackgroundService] No valid token found. Stopping service.');
    service.stopSelf();
    return true;
  }

  // Ensure notification is ongoing (non-removable)
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'offline_notification_channel',
        'Talkliner Service',
        channelDescription: 'Background service for offline notifications',
        importance:
            Importance.low, // Low importance for persistent service notif
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    888,
    'Talkliner Service',
    'Initializing...',
    platformChannelSpecifics,
  );

  // Socket.io Connection Logic
  _connectToSocket(service, flutterLocalNotificationsPlugin, token.token);

  return true;
}

void _connectToSocket(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String token,
) {
  final socketUrl = AppConfig().socketUrl();
  debugPrint('[BackgroundService] Connecting to Socket.io: $socketUrl');

  io.Socket socket = io.io(
    socketUrl,
    io.OptionBuilder()
        .setPath("/ws")
        .setTransports(['websocket', 'polling'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setTimeout(20000)
        .setAuth({'token': token})
        .build(),
  );

  socket.onConnect((_) {
    debugPrint('[BackgroundService] Connected to Socket.io');
    service.invoke('update', {"status": "Connected"});
    _updateServiceNotification(
      flutterLocalNotificationsPlugin,
      "Connected to Server",
    );
  });

  socket.onDisconnect((_) {
    debugPrint('[BackgroundService] Disconnected from Socket.io');
    service.invoke('update', {"status": "Disconnected"});
    _updateServiceNotification(flutterLocalNotificationsPlugin, "Disconnected");
  });

  // Listen for new messages
  socket.on('notification', (data) {
    try {
      debugPrint('[BackgroundService] Received new_message: $data');

      String content = data['content'] ?? "New Message";

      _showNotification(
        flutterLocalNotificationsPlugin,
        'New Message',
        content,
      );
    } catch (e) {
      debugPrint('[BackgroundService] Error processing new_message: $e');
    }
  });

  socket.connect();
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String title,
  String body,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'offline_notification_channel',
        'Offline Notifications',
        channelDescription: 'Notifications received while app is in background',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond, // Unique ID
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<void> _updateServiceNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String content,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'offline_notification_channel',
        'Talkliner Service',
        channelDescription: 'Background service for offline notifications',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    888,
    'Talkliner Service',
    content,
    platformChannelSpecifics,
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Notification Channel Setup for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'offline_notification_channel', // id
    'Offline Notifications', // title
    description:
        'This channel is used for offline notifications.', // description
    importance: Importance.high,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'offline_notification_channel',
      initialNotificationTitle: 'Talkliner Service',
      initialNotificationContent: 'Connected to Server',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onStart,
    ),
  );

  // We don't start it here anymore automatically if you want manual control,
  // but keeping startService() makes it auto-run if user is already logged in (checked in onStart).
  service.startService();
}
