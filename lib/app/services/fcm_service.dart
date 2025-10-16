import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'dart:convert';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  static Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[NOTIFICATION] User granted permission');
    } else {
      debugPrint('[NOTIFICATION] User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('[NOTIFICATION] FCM Token: $token');

    // Configure foreground notifications
    await _configureForegroundNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Handle local notification taps
    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Parse the payload and handle navigation
          _handleLocalNotificationTap(response.payload!);
        }
      },
    );

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      debugPrint('[NOTIFICATION] New FCM Token: $token');
      // Send token to your server
    });
  }

  // Configure Android notification channel
  static Future<void> _configureForegroundNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('=== FCM FOREGROUND MESSAGE RECEIVED ===');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title} - ${message.notification?.body}');

    // Get current screen
    String? currentScreen = Get.currentRoute;
    debugPrint('[NOTIFICATION] Current screen: $currentScreen');

    // Check if we should show notification
    bool shouldShow = message.notification != null && _shouldShowNotification(message, currentScreen);
    debugPrint('[NOTIFICATION] Should show notification: $shouldShow');

    if (shouldShow) {
      debugPrint('[NOTIFICATION] ✅ Showing local notification');
      _showLocalNotification(message);
    } else {
      debugPrint('[NOTIFICATION] ❌ Suppressing notification');
      if (currentScreen == Routes.chat) {
        debugPrint('[NOTIFICATION] Reason: User is on chat screen ($currentScreen)');
      } else if (message.notification == null) {
        debugPrint('[NOTIFICATION] Reason: No notification payload');
      }
    }
    debugPrint('=== END FCM FOREGROUND MESSAGE ===');
  }

  // Determine if notification should be shown
  static bool _shouldShowNotification(RemoteMessage message, String? currentScreen) {
    // Don't show notification if user is on chat screen
    if (currentScreen == Routes.chat) {
      return false;
    }

    // Extract chat information from notification (for future use)
    // final Map<String, dynamic> data = message.data;
    // final String? chatId = data['chat_id'];
    // final String? messageId = data['message_id'];

    // You can add more sophisticated logic here
    // For example, if you want to suppress notifications only when viewing the same chat:
    // if (currentScreen == Routes.chat && _isViewingSameChat(chatId)) {
    //   return false;
    // }

    return true;
  }

  // Check if user is viewing the same chat as the notification (for future use)
  // static bool _isViewingSameChat(String? notificationChatId) {
  //   if (notificationChatId == null) return false;
  //   
  //   try {
  //     // Get current route arguments to check if we're viewing the same chat
  //     final dynamic currentArguments = Get.arguments;
  //     
  //     if (currentArguments is UserModel) {
  //       // If arguments is UserModel, you might need to extract chat ID differently
  //       // This depends on how your chat screen is set up
  //       return false; // For now, suppress all notifications when on chat screen
  //     } else if (currentArguments is Map) {
  //       // If arguments is a Map, check for chat ID
  //       final String? currentChatId = currentArguments['chatId'];
  //       return currentChatId == notificationChatId;
  //     }
  //   } catch (e) {
  //     debugPrint('Error checking current chat: $e');
  //   }
  //   
  //   return false;
  // }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[NOTIFICATION] Notification tapped: ${message.data}');
    
    try {
      // Extract notification data
      final Map<String, dynamic> data = message.data;
      final String? messageId = data['message_id'];
      final String? clickAction = data['click_action'];
      final String? chatId = data['chat_id'];
      
      // Parse user data - Firebase converts it to a JSON string
      UserModel? user;
      if (data['user'] != null) {
        try {
          // Check if it's already a Map or a JSON string
          if (data['user'] is Map) {
            // If it's already a Map (shouldn't happen with Firebase, but just in case)
            final Map<String, dynamic> userData = data['user'] as Map<String, dynamic>;
            user = UserModel.fromJson(userData);
          } else {
            // It's a JSON string, parse it first
            final String userJsonString = data['user'] as String;
            final Map<String, dynamic> userData = jsonDecode(userJsonString);
            user = UserModel.fromJson(userData);
          }
          debugPrint('[NOTIFICATION] Parsed User: ${user.displayName} (${user.username})');
        } catch (e) {
          debugPrint('[NOTIFICATION] Error parsing user data: $e');
          debugPrint('[NOTIFICATION] User data type: ${data['user'].runtimeType}');
          debugPrint('[NOTIFICATION] User data: ${data['user']}');
        }
      }
      
      // Determine navigation based on click_action or default to chat
      String? navigationType = clickAction?.toLowerCase();
      if (navigationType == null || navigationType.isEmpty) {
        navigationType = 'chat'; // Default to chat if no click_action
      }
      
      // Handle navigation based on click_action
      _navigateToScreen(
        type: navigationType,
        chatId: chatId,
        user: user,
        messageId: messageId,
      );
      
    } catch (e) {
      debugPrint('[NOTIFICATION] Error handling notification tap: $e');
      // Fallback navigation
      _navigateToScreen();
    }
  }

  // Navigate to appropriate screen based on notification data
  static void _navigateToScreen({
    String? type,
    String? screen,
    String? chatId,
    String? userId,
    String? userName,
    UserModel? user,
    String? messageId,
  }) {
    // Wait for GetX to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        // Handle specific screen navigation
        if (screen != null) {
          switch (screen.toLowerCase()) {
            case 'home':
              Get.offAllNamed(Routes.home);
              break;
            case 'chat':
              if (chatId != null) {
                // Navigate to chat with specific chat ID
                Get.toNamed(
                  Routes.chat,
                  arguments: user,
                );
              } else {
                Get.toNamed(Routes.chat);
              }
              break;
            case 'contacts':
              // Navigate to home and set contacts tab
              Get.offAllNamed(Routes.home);
              // You might want to set a specific tab index here
              break;
            case 'settings':
              Get.toNamed(Routes.settings);
              break;
            case 'profile':
              Get.toNamed(Routes.userSettings);
              break;
            default:
              // Default to home
              Get.offAllNamed(Routes.home);
          }
        }
        // Handle notification type-based navigation
        else if (type != null) {
          switch (type.toLowerCase()) {
            case 'chat':
            case 'message':
            case 'show_chat':
              if (chatId != null && user != null) {
                // Navigate to chat with complete user object
                Get.toNamed(Routes.chat, arguments: user);
              } else if (chatId != null) {
                // Navigate to chat with basic data
                Get.toNamed(
                  Routes.chat,
                  arguments: {
                    'chatId': chatId,
                    'userId': userId,
                    'userName': userName,
                    'messageId': messageId,
                  },
                );
              } else {
                // Navigate to home (contacts tab)
                Get.offAllNamed(Routes.home);
              }
              break;
            case 'call':
            case 'ptt':
              // Navigate to home (push-to-talk tab)
              Get.offAllNamed(Routes.home);
              break;
            case 'contact':
            case 'user':
              // Navigate to home (contacts tab)
              Get.offAllNamed(Routes.home);
              break;
            case 'emergency':
              // Navigate to home and show emergency notification
              Get.offAllNamed(Routes.home);
              // You could show a dialog or specific emergency screen here
              break;
            default:
              // Default to home
              Get.offAllNamed(Routes.home);
          }
        }
        // If no specific type or screen, navigate to home
        else {
          Get.offAllNamed(Routes.home);
        }
      } catch (e) {
        debugPrint('[NOTIFICATION] Error navigating from notification: $e');
        // Fallback to home
        Get.offAllNamed(Routes.home);
      }
    });
  }

  // Handle local notification tap
  static void _handleLocalNotificationTap(String payload) {
    try {
      // Parse payload as JSON-like string
      // The payload should contain navigation data
      debugPrint('[NOTIFICATION] Local notification tapped with payload: $payload');

      if(payload.contains('message_id')) {
        debugPrint('Message ID: $payload');
      }

      // Simple parsing - you might want to use proper JSON parsing
      // if (payload.contains('chatId')) {
      //   // Extract chat information and navigate
      //   _navigateToScreen(type: 'chat');
      // } else if (payload.contains('call')) {
      //   _navigateToScreen(type: 'call');
      // } else {
      //   _navigateToScreen(type: 'general');
      // }
    } catch (e) {
      debugPrint('Error handling local notification tap: $e');
      _navigateToScreen(); // Default navigation
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // Get FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Public method to handle navigation from external sources
  static void handleNotificationNavigation({
    String? type,
    String? screen,
    String? chatId,
    String? userId,
    String? userName,
    UserModel? user,
    String? messageId,
  }) {
    _navigateToScreen(
      type: type,
      screen: screen,
      chatId: chatId,
      userId: userId,
      userName: userName,
      user: user,
      messageId: messageId,
    );
  }

  // Public method to check if notifications should be suppressed
  static bool shouldSuppressNotification(String? currentRoute, String? notificationChatId) {
    // Don't show notification if user is on chat screen
    if (currentRoute == Routes.chat) {
      return true;
    }
    
    // Add more conditions as needed
    return false;
  }

  // Public method to update notification suppression settings
  static void setNotificationSuppression({
    bool suppressOnChatScreen = true,
    bool suppressOnSameChat = false,
  }) {
    // You can implement persistent settings here
    // For example, using SharedPreferences or GetStorage
    debugPrint('Notification suppression settings updated: suppressOnChatScreen=$suppressOnChatScreen, suppressOnSameChat=$suppressOnSameChat');
  }
}
