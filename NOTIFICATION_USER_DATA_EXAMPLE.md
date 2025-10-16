# Notification User Data Example

## Problem Fixed ✅

The error `type 'String' is not a subtype of type 'Map<String, dynamic>'` occurred because Firebase notification data values are always strings, even when they contain JSON data.

## Solution

The `FCMService` now properly parses JSON strings from notification data:

```dart
// Parse user data if it exists as JSON string
UserModel? user;
if (data['user'] != null) {
  try {
    // Parse the JSON string to Map
    final Map<String, dynamic> userJson = jsonDecode(data['user']);
    user = UserModel.fromJson(userJson);
    debugPrint('Parsed User: $user');
  } catch (e) {
    debugPrint('Error parsing user data: $e');
  }
}
```

## Server-Side Notification Examples

### 1. **Send User Object as JSON String**
```javascript
// Node.js/Express example
const user = {
  id: "user_123",
  name: "John Doe",
  email: "john@example.com",
  avatar: "https://example.com/avatar.jpg"
};

const message = {
  notification: {
    title: "New Message",
    body: "You have a new message from John"
  },
  data: {
    type: "chat",
    chatId: "chat_456",
    user: JSON.stringify(user)  // Convert to JSON string
  },
  token: fcmToken
};

admin.messaging().send(message);
```

### 2. **Alternative: Send Individual User Fields**
```javascript
const message = {
  notification: {
    title: "New Message", 
    body: "You have a new message"
  },
  data: {
    type: "chat",
    chatId: "chat_456",
    userId: "user_123",
    userName: "John Doe",
    userEmail: "john@example.com"
  },
  token: fcmToken
};
```

### 3. **PHP Example**
```php
<?php
$user = [
    'id' => 'user_123',
    'name' => 'John Doe',
    'email' => 'john@example.com',
    'avatar' => 'https://example.com/avatar.jpg'
];

$message = [
    'notification' => [
        'title' => 'New Message',
        'body' => 'You have a new message from John'
    ],
    'data' => [
        'type' => 'chat',
        'chatId' => 'chat_456',
        'user' => json_encode($user)  // Convert to JSON string
    ],
    'token' => $fcmToken
];

// Send via Firebase Admin SDK or HTTP API
?>
```

### 4. **Python Example**
```python
import json
from firebase_admin import messaging

user = {
    'id': 'user_123',
    'name': 'John Doe',
    'email': 'john@example.com',
    'avatar': 'https://example.com/avatar.jpg'
}

message = messaging.Message(
    notification=messaging.Notification(
        title='New Message',
        body='You have a new message from John'
    ),
    data={
        'type': 'chat',
        'chatId': 'chat_456',
        'user': json.dumps(user)  # Convert to JSON string
    },
    token=fcm_token
)

response = messaging.send(message)
```

## Flutter App Handling

The app now handles both approaches:

### **With UserModel Object:**
```dart
// When user data is sent as JSON string
if (data['user'] != null) {
  final Map<String, dynamic> userJson = jsonDecode(data['user']);
  final UserModel user = UserModel.fromJson(userJson);
  
  // Navigate with complete user object
  Get.toNamed(Routes.chat, arguments: user);
}
```

### **With Individual Fields:**
```dart
// When individual user fields are sent
Get.toNamed(Routes.chat, arguments: {
  'chatId': chatId,
  'userId': userId,
  'userName': userName,
});
```

## Key Points

1. **All Firebase data values are strings** - even JSON objects must be stringified
2. **Use `jsonDecode()`** to convert JSON strings back to objects
3. **Error handling** is included for malformed JSON
4. **Fallback support** for both approaches (UserModel object vs individual fields)
5. **Debug logging** helps troubleshoot parsing issues

## Testing

Send a test notification with user data:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Test Message",
      "body": "Testing user data parsing"
    },
    "data": {
      "type": "chat",
      "chatId": "test_chat",
      "user": "{\"id\":\"user_123\",\"name\":\"Test User\",\"email\":\"test@example.com\"}"
    }
  }'
```

The app should now properly parse the user data and navigate to the chat screen with the complete UserModel object! 🎯
