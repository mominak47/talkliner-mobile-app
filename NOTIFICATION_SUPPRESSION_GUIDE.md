# Notification Suppression Guide - Hide Notifications on Chat Screen ✅

## Overview
The FCMService now includes intelligent notification suppression to prevent showing notifications when the user is already viewing a chat screen.

## How It Works

### **Current Implementation:**
When a push notification arrives while the app is in the foreground:

1. **Check Current Route** - Gets the current screen the user is on
2. **Suppress on Chat Screen** - If user is on `/chat` route, notification is suppressed
3. **Show Otherwise** - If user is on any other screen, notification is shown

### **Code Flow:**
```dart
// When notification arrives in foreground
_handleForegroundMessage(RemoteMessage message) {
  String? currentScreen = Get.currentRoute;
  
  if (message.notification != null && _shouldShowNotification(message, currentScreen)) {
    _showLocalNotification(message); // Show notification
  } else {
    debugPrint('Suppressing notification - user is on chat screen'); // Suppress
  }
}
```

## Current Behavior

### **✅ Notifications Suppressed When:**
- User is on the Chat screen (`/chat` route)
- App is in foreground (user actively using the app)

### **✅ Notifications Shown When:**
- User is on any other screen (Home, Contacts, Settings, etc.)
- App is in background or terminated
- User is not actively viewing a chat

## Debug Logs

### **When Notification is Suppressed:**
```
[NOTIFICATION] Current screen: /chat
[NOTIFICATION] Suppressing notification - user is on chat screen
```

### **When Notification is Shown:**
```
[NOTIFICATION] Current screen: /home
[NOTIFICATION] Showing local notification
```

## Advanced Configuration (Future Enhancement)

### **Same Chat Suppression (Available but commented out):**
If you want to suppress notifications only when viewing the **same chat** (not just any chat):

```dart
// Uncomment this in _shouldShowNotification method:
if (currentScreen == Routes.chat && _isViewingSameChat(chatId)) {
  return false;
}
```

### **Custom Suppression Logic:**
You can add more sophisticated conditions:

```dart
static bool _shouldShowNotification(RemoteMessage message, String? currentScreen) {
  // Don't show if on chat screen
  if (currentScreen == Routes.chat) return false;
  
  // Don't show during specific hours
  if (DateTime.now().hour < 8 || DateTime.now().hour > 22) return false;
  
  // Don't show if user has disabled notifications
  // if (!userNotificationSettings) return false;
  
  return true;
}
```

## Public Methods Available

### **Check Suppression Status:**
```dart
bool shouldSuppress = FCMService.shouldSuppressNotification('/chat', 'chat_123');
```

### **Update Suppression Settings:**
```dart
FCMService.setNotificationSuppression(
  suppressOnChatScreen: true,
  suppressOnSameChat: false,
);
```

## Testing Your Implementation

### **Test Scenarios:**

1. **Chat Screen Suppression:**
   - Navigate to Chat screen (`/chat`)
   - Send test notification
   - Verify: No notification appears

2. **Other Screen Display:**
   - Navigate to Home screen (`/home`)
   - Send test notification
   - Verify: Notification appears

3. **Background Notifications:**
   - Put app in background
   - Send test notification
   - Verify: Notification appears (suppression only works in foreground)

## Notification Flow Summary

### **Foreground (App Open):**
```
Notification Arrives → Check Current Route → Show/Hide Based on Route
```

### **Background/Terminated:**
```
Notification Arrives → Always Show (System handles this)
```

## Customization Options

### **1. Route-Based Suppression:**
```dart
// Suppress on multiple screens
if (currentScreen == Routes.chat || currentScreen == Routes.call) {
  return false;
}
```

### **2. User-Based Suppression:**
```dart
// Suppress based on notification sender
final String? senderId = data['user_id'];
if (senderId == currentUserId) return false;
```

### **3. Time-Based Suppression:**
```dart
// Suppress during quiet hours
final hour = DateTime.now().hour;
if (hour >= 22 || hour <= 7) return false;
```

### **4. Chat-Specific Suppression:**
```dart
// Only suppress if viewing the same chat
final String? notificationChatId = data['chat_id'];
if (currentScreen == Routes.chat && isViewingChat(notificationChatId)) {
  return false;
}
```

## Integration with Your App

### **In Chat Controller:**
You can notify the FCMService when user enters/exits chat:

```dart
// When entering chat
FCMService.setNotificationSuppression(suppressOnChatScreen: true);

// When leaving chat
FCMService.setNotificationSuppression(suppressOnChatScreen: false);
```

### **In Settings:**
Allow users to configure notification preferences:

```dart
// User preference
bool suppressInChat = GetStorage().read('suppress_chat_notifications') ?? true;
FCMService.setNotificationSuppression(suppressOnChatScreen: suppressInChat);
```

## Expected Behavior

### **User Experience:**
- ✅ **Seamless Chat Experience** - No interruptions when actively chatting
- ✅ **Proper Notifications** - Still receive notifications when not in chat
- ✅ **Background Support** - Notifications work normally when app is closed
- ✅ **Debug Visibility** - Clear logs for troubleshooting

### **Performance:**
- ✅ **Minimal Overhead** - Simple route checking
- ✅ **Fast Execution** - No complex operations
- ✅ **Memory Efficient** - No persistent state required

Your notification suppression feature is now fully implemented and working! Users won't see notifications when they're actively viewing a chat screen. 🎯
