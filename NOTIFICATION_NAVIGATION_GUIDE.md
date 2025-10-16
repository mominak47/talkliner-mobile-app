# Notification Navigation Guide

## Overview
This guide explains how to handle notification taps and navigate to the appropriate screens in your Talkliner app.

## 🎯 Where Notification Tap Events Are Handled

The notification tap events are handled in **`lib/app/services/fcm_service.dart`** in the following methods:

### 1. **`_handleNotificationTap(RemoteMessage message)`**
- Handles FCM notification taps (background/terminated app)
- Extracts data from the notification payload
- Calls `_navigateToScreen()` with the extracted data

### 2. **`_handleLocalNotificationTap(String payload)`**
- Handles local notification taps (foreground notifications)
- Parses the payload string
- Calls `_navigateToScreen()` with parsed data

### 3. **`_navigateToScreen()`** - Main Navigation Logic
- Contains all the navigation logic
- Supports both `screen` and `type` based navigation
- Includes error handling and fallbacks

## 📱 Supported Notification Types

### **Screen-Based Navigation**
Send notifications with `screen` field:

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "screen": "chat",
    "chatId": "123",
    "userId": "456",
    "userName": "John Doe"
  }
}
```

**Supported screens:**
- `home` - Navigate to home screen
- `chat` - Navigate to chat screen
- `contacts` - Navigate to contacts tab
- `settings` - Navigate to settings
- `profile` - Navigate to user profile

### **Type-Based Navigation**
Send notifications with `type` field:

```json
{
  "notification": {
    "title": "New Message",
    "body": "You have a new message"
  },
  "data": {
    "type": "chat",
    "chatId": "123",
    "userId": "456"
  }
}
```

**Supported types:**
- `chat` / `message` - Navigate to chat screen
- `call` / `ptt` - Navigate to push-to-talk tab
- `contact` / `user` - Navigate to contacts tab
- `emergency` - Navigate to home with emergency handling
- `general` - Navigate to home (default)

## 🚀 Usage Examples

### **1. Chat Message Notification**
```json
{
  "notification": {
    "title": "New Message",
    "body": "John: Hey, how are you?"
  },
  "data": {
    "type": "chat",
    "chatId": "chat_123",
    "userId": "user_456",
    "userName": "John Doe"
  }
}
```
**Result:** Opens chat screen with the specific chat and user data.

### **2. Call Notification**
```json
{
  "notification": {
    "title": "Incoming Call",
    "body": "John is calling you"
  },
  "data": {
    "type": "call",
    "userId": "user_456",
    "userName": "John Doe"
  }
}
```
**Result:** Navigates to home screen (push-to-talk tab).

### **3. Emergency Notification**
```json
{
  "notification": {
    "title": "EMERGENCY ALERT",
    "body": "Emergency situation detected"
  },
  "data": {
    "type": "emergency",
    "priority": "high"
  }
}
```
**Result:** Navigates to home screen with emergency handling.

### **4. Direct Screen Navigation**
```json
{
  "notification": {
    "title": "Settings Update",
    "body": "Your settings have been updated"
  },
  "data": {
    "screen": "settings"
  }
}
```
**Result:** Opens settings screen directly.

## 🔧 Programmatic Navigation

You can also trigger navigation programmatically:

```dart
import 'package:talkliner/app/services/fcm_service.dart';

// Navigate to chat
FCMService.handleNotificationNavigation(
  type: 'chat',
  chatId: 'chat_123',
  userId: 'user_456',
  userName: 'John Doe',
);

// Navigate to specific screen
FCMService.handleNotificationNavigation(
  screen: 'settings',
);
```

## 🛠️ Customization

### **Adding New Navigation Types**

1. **Add to `_navigateToScreen()` method:**
```dart
case 'your_new_type':
  // Your navigation logic
  Get.toNamed('/your-new-route');
  break;
```

2. **Update your server to send the new type:**
```json
{
  "data": {
    "type": "your_new_type",
    "additionalData": "value"
  }
}
```

### **Adding New Screens**

1. **Add route to `Routes` class:**
```dart
static const yourNewScreen = '/your-new-screen';
```

2. **Add page to `Pages` class:**
```dart
GetPage(
  name: Routes.yourNewScreen,
  page: () => YourNewScreen(),
),
```

3. **Add navigation case:**
```dart
case 'your_new_screen':
  Get.toNamed(Routes.yourNewScreen);
  break;
```

## 🔍 Debugging

### **Check Notification Data**
The service logs all notification data:
```dart
debugPrint('Notification tapped: ${message.data}');
```

### **Check Navigation Errors**
Navigation errors are caught and logged:
```dart
debugPrint('Error navigating from notification: $e');
```

## ⚠️ Important Notes

1. **Timing:** Navigation is delayed by 500ms to ensure GetX is ready
2. **Fallback:** All navigation errors fallback to home screen
3. **Background:** Background message handler also initializes Firebase
4. **Local vs Remote:** Both local and remote notifications are handled
5. **Arguments:** Chat screen receives arguments for user/chat data

## 🎯 Best Practices

1. **Always include relevant IDs** (chatId, userId) in notification data
2. **Use descriptive types** for better organization
3. **Test both foreground and background** notification handling
4. **Include fallback navigation** for unknown types
5. **Log notification data** for debugging

This system provides a robust foundation for handling notification taps and navigating to the appropriate screens in your Talkliner app!
