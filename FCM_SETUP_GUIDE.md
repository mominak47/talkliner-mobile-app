# FCM (Firebase Cloud Messaging) Setup Guide

## Overview
This guide documents the complete FCM setup for the Talkliner app, enabling push notifications for both iOS and Android platforms.

## ✅ What's Been Configured

### 1. **Firebase Configuration Files**
- **Android**: `android/app/google-services.json` ✅
- **iOS**: `ios/Runner/GoogleService-Info.plist` ✅
- **Package Name**: `com.steigenberg.talkliner` ✅

### 2. **Android Configuration**
- ✅ Added Google Services plugin to `android/app/build.gradle.kts`
- ✅ Added Google Services classpath to `android/build.gradle.kts`
- ✅ Added core library desugaring for `flutter_local_notifications`
- ✅ Package name updated to `com.steigenberg.talkliner`

### 3. **iOS Configuration**
- ✅ Firebase configuration file copied to iOS project
- ✅ Background modes already configured for remote notifications
- ✅ Bundle ID matches: `com.steigenberg.talkliner`

### 4. **Flutter Dependencies**
- ✅ `firebase_core: ^3.15.2`
- ✅ `firebase_messaging: ^15.2.10`
- ✅ `flutter_local_notifications: ^18.0.1`
- ✅ `timezone: ^0.9.4`

### 5. **FCM Service Implementation**
- ✅ Created `lib/libraries/fcm_service.dart` - Singleton FCM service
- ✅ Created `lib/libraries/fcm_usage_examples.dart` - Usage examples
- ✅ Integrated FCM initialization in `main.dart`

## 🔧 FCM Service Features

### **Core Functionality**
- 🔔 **Foreground Messages**: Shows local notifications when app is open
- 🌙 **Background Messages**: Handles notifications when app is closed
- 📱 **App Launch**: Handles notifications that open the app
- 🔄 **Token Management**: Automatic token refresh and management
- 📋 **Topic Subscription**: Subscribe/unsubscribe to specific topics

### **Notification Types Supported**
- 💬 **Chat Messages**: `chat_${chatId}` topic
- 📞 **Calls**: `calls` topic  
- 🎤 **PTT Messages**: `ptt` topic
- 👤 **User-specific**: `user_${userId}` topic
- 📢 **General**: `general` topic

## 🚀 Usage Examples

### **Initialize FCM (Already done in main.dart)**
```dart
await FCMService().initialize();
```

### **User Login/Logout**
```dart
// On login
await FCMUsageExamples.onUserLogin(userId);

// On logout  
await FCMUsageExamples.onUserLogout(userId);
```

### **Subscribe to Specific Topics**
```dart
// Subscribe to chat notifications
await FCMUsageExamples.subscribeToChat(chatId);

// Subscribe to PTT notifications
await FCMUsageExamples.subscribeToPTT();
```

### **Get FCM Token**
```dart
String? token = await FCMService().getToken();
// Send this token to your server
```

## 📱 Testing Push Notifications

### **Using Firebase Console**
1. Go to Firebase Console → Your Project → Messaging
2. Create a new campaign
3. Target by topic (e.g., `general`, `user_123`, `chat_456`)
4. Send test message

### **Example Payloads**
```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "type": "chat",
    "chatId": "123",
    "senderName": "John Doe"
  },
  "topic": "chat_123"
}
```

## 🔍 Troubleshooting

### **Common Issues**
1. **Build Errors**: Run `flutter clean && flutter pub get`
2. **Token Issues**: Check Firebase configuration files
3. **iOS Permissions**: Ensure notification permissions are granted
4. **Background Messages**: Verify background modes in Info.plist

### **Debug Commands**
```bash
# Clean and rebuild
flutter clean && flutter pub get

# Build Android
flutter build apk --debug

# Build iOS  
flutter build ios --no-codesign

# Run with verbose logging
flutter run --verbose
```

## 📋 Next Steps

### **Server Integration**
1. **Store FCM Tokens**: Save tokens in your database
2. **Send Notifications**: Use Firebase Admin SDK or REST API
3. **Topic Management**: Subscribe users to relevant topics
4. **Token Refresh**: Handle token updates on your server

### **Advanced Features**
1. **Rich Notifications**: Add images, actions, and custom layouts
2. **Silent Notifications**: Update app data without showing notifications
3. **Analytics**: Track notification engagement
4. **A/B Testing**: Test different notification strategies

## 🔐 Security Considerations

1. **Token Storage**: Store FCM tokens securely on your server
2. **Topic Access**: Control who can subscribe to which topics
3. **Message Validation**: Validate notification payloads
4. **Rate Limiting**: Implement rate limiting for notification sending

## 📞 Support

If you encounter issues:
1. Check Firebase Console for delivery status
2. Verify configuration files are in correct locations
3. Test with Firebase Console test messages
4. Check device logs for FCM-related errors

---

**Status**: ✅ **FCM Setup Complete**
**Last Updated**: $(date)
**Package Name**: `com.steigenberg.talkliner` 