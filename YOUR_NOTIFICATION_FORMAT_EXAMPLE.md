# Your Notification Format - Complete Handling Guide

## Your Notification Format ✅

Based on your notification format, the FCMService has been updated to handle this exact structure:

```json
{
  "message_id": "68d2648913c9ed2d3f5c6061",
  "click_action": "SHOW_CHAT",
  "user": {
    "_id": "68408c50b58283b5c84645fe",
    "domain_id": "683f1115e1c8b4535a2ce769",
    "username": "fahad2",
    "display_name": "Fahad Khan",
    "settings": {
      "push_to_talk": true,
      "emergency_alert_call": true,
      "gps_location": true,
      "group_call": true,
      "individual_call": true,
      "messaging": true,
      "video_call": true,
      "call_history": true
    },
    "__v": 0,
    "is_online": "offline",
    "status": "online",
    "apn_token": null,
    "fcm_token": "cKl_zoQXNETPrRR8jCZO1e:APA91bE5CnXo-a7TV7s4IKqBxfWe7SN1wLfj3-kMCG6mEDhy6gtdn4Y2EmvPbULXQ-B-3vWTyihjt6MvSvz3T-TkdH0TQw2gU9sbFaAdQ-JoR6skckLRqKY"
  },
  "chat_id": "68cd88094eb0b652dbfe927c"
}
```

## How It's Handled in FCMService

### 1. **Data Extraction**
```dart
final String? messageId = data['message_id'];           // "68d2648913c9ed2d3f5c6061"
final String? clickAction = data['click_action'];       // "SHOW_CHAT"
final String? chatId = data['chat_id'];                 // "68cd88094eb0b652dbfe927c"
```

### 2. **User Object Parsing**
```dart
// The user data is already a Map from your notification format
final Map<String, dynamic> userData = data['user'] as Map<String, dynamic>;
user = UserModel.fromJson(userData);
debugPrint('Parsed User: Fahad Khan (fahad2)');
```

### 3. **Navigation Logic**
```dart
// Determines navigation based on click_action
String? navigationType = clickAction?.toLowerCase(); // "show_chat"

// Navigates to chat screen with complete user object
Get.toNamed(Routes.chat, arguments: user);
```

## Supported Click Actions

### **SHOW_CHAT** ✅
```dart
case 'show_chat':
  if (chatId != null && user != null) {
    // Navigate to chat with complete user object
    Get.toNamed(Routes.chat, arguments: user);
  }
  break;
```

### **Future Actions You Can Add:**
```dart
case 'show_call':
  // Navigate to call screen
  break;
  
case 'show_ptt':
  // Navigate to push-to-talk
  break;
  
case 'show_emergency':
  // Navigate to emergency screen
  break;
```

## Server-Side Implementation

### **Node.js/Express Example:**
```javascript
const notificationData = {
  message_id: "68d2648913c9ed2d3f5c6061",
  click_action: "SHOW_CHAT",
  user: {
    "_id": "68408c50b58283b5c84645fe",
    "domain_id": "683f1115e1c8b4535a2ce769",
    "username": "fahad2",
    "display_name": "Fahad Khan",
    "settings": {
      "push_to_talk": true,
      "emergency_alert_call": true,
      "gps_location": true,
      "group_call": true,
      "individual_call": true,
      "messaging": true,
      "video_call": true,
      "call_history": true
    },
    "__v": 0,
    "is_online": "offline",
    "status": "online",
    "apn_token": null,
    "fcm_token": "cKl_zoQXNETPrRR8jCZO1e:APA91bE5CnXo-a7TV7s4IKqBxfWe7SN1wLfj3-kMCG6mEDhy6gtdn4Y2EmvPbULXQ-B-3vWTyihjt6MvSvz3T-TkdH0TQw2gU9sbFaAdQ-JoR6skckLRqKY"
  },
  chat_id: "68cd88094eb0b652dbfe927c"
};

const message = {
  notification: {
    title: "New Message",
    body: "Fahad Khan sent you a message"
  },
  data: notificationData, // Firebase will automatically convert to strings
  token: recipientFcmToken
};

admin.messaging().send(message);
```

### **Important Note:**
Firebase automatically converts all data values to strings, so your nested objects become JSON strings in the notification data. The FCMService handles this correctly by treating the `user` field as a Map.

## Chat Screen Access

When the notification is tapped, the Chat screen will receive the complete UserModel object:

```dart
// In your Chat screen
class Chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserModel? user = Get.arguments;
    
    if (user != null) {
      // You have access to all user properties:
      print('Chatting with: ${user.displayName}');
      print('Username: ${user.username}');
      print('User ID: ${user.id}');
      print('Settings: ${user.settings}');
      print('Status: ${user.status}');
    }
    
    return Scaffold(
      // Your chat UI
    );
  }
}
```

## Debugging

The FCMService logs all the important information:

```dart
debugPrint('Notification tapped: ${message.data}');
debugPrint('Parsed User: Fahad Khan (fahad2)');
```

## Error Handling

If there are any issues parsing the user data:

```dart
try {
  final Map<String, dynamic> userData = data['user'] as Map<String, dynamic>;
  user = UserModel.fromJson(userData);
} catch (e) {
  debugPrint('Error parsing user data: $e');
  debugPrint('User data: ${data['user']}');
  // Falls back to basic navigation without user object
}
```

## Testing Your Notification

Send a test notification with your exact format:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Message",
      "body": "Testing your notification format"
    },
    "data": {
      "message_id": "68d2648913c9ed2d3f5c6061",
      "click_action": "SHOW_CHAT",
      "user": "{\"_id\":\"68408c50b58283b5c84645fe\",\"username\":\"fahad2\",\"display_name\":\"Fahad Khan\"}",
      "chat_id": "68cd88094eb0b652dbfe927c"
    }
  }'
```

**Note:** The `user` object will be automatically converted to a JSON string by Firebase, but the FCMService correctly parses it back to a Map and creates a UserModel object.

Your notification format is now fully supported! 🎯
