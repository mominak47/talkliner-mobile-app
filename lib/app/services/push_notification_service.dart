import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
  // If it's a call, CallKit might handle it natively if payload is correct.
  // Or we trigger it manually here if strictly data message.
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<PushNotificationService> onInitService() async {
    await _initialize();
    return this;
  }

  Future<void> _initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get APNS Token for iOS
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        debugPrint('APNS Token: $apnsToken');
      }

      // Get FCM Token
      String? fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $fcmToken');
      // TODO: Save or update FCM token to backend via AuthController or similar

      // Foreground Message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification}',
          );
          // Ensure we don't show double notification if CallKit shows one
        }

        _handleMessage(message);
      });

      // Background/Terminated Message Handler setup
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Open from Terminated state
      FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
      ) {
        if (message != null) {
          _handleMessage(message);
        }
      });

      // Open from Background state
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    // Handle Call VOIP Payload
    if (message.data['type'] == 'call') {
      _showIncomingCall(message.data);
    }
  }

  Future<void> _showIncomingCall(Map<String, dynamic> data) async {
    // Basic CallKit trigger on data message
    // Note: Better to handle this via existing CallController logic if possible,
    // but here we ensure CallKit shows up.

    var params = CallKitParams(
      id: data['call_id'] ?? const Uuid().v4(),
      nameCaller: data['caller_name'] ?? 'Unknown',
      appName: 'Talkliner',
      avatar: data['caller_avatar'],
      handle: data['caller_handle'] ?? '', // Phone number or similar
      type: 0, // 0 - Audio, 1 - Video
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: 30000,
      extra: data,
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}
