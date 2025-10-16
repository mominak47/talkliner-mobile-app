# Custom CallKit Plugin for Flutter

This document describes the custom CallKit plugin implementation for the Talkliner Flutter app, which provides native iOS CallKit integration.

## Overview

The custom CallKit plugin allows the Flutter app to integrate with iOS CallKit framework, providing native call handling capabilities including:

- Incoming call notifications
- Outgoing call initiation
- Call answering/declining
- Call hold/mute functionality
- Call state management
- Native iOS call interface

## Architecture

The plugin consists of three main components:

1. **Dart Interface** (`lib/services/callkit_plugin.dart`)
2. **iOS Native Implementation** (`ios/Runner/CallKitHandler.swift`)
3. **Integration Layer** (`lib/services/call_service.dart`)

## Files Structure

```
lib/
├── services/
│   ├── callkit_plugin.dart          # Main Dart interface
│   └── call_service.dart            # Integration with existing call system
├── examples/
│   └── callkit_usage_example.dart   # Usage example
ios/
└── Runner/
    ├── CallKitHandler.swift         # iOS native implementation
    └── AppDelegate.swift            # Integration point
```

## Features

### Core Functionality

- **Initialize CallKit**: Configure CallKit with app settings
- **Show Incoming Call**: Display native incoming call interface
- **Start Outgoing Call**: Initiate outgoing calls through CallKit
- **Answer/Decline Calls**: Handle call actions through native interface
- **End Calls**: Terminate active calls
- **Call State Management**: Track and manage call states
- **Audio Controls**: Mute, hold, and speaker functionality
- **Event Handling**: Real-time call event notifications

### Call States

- `incoming`: Call is incoming and waiting for user action
- `outgoing`: Call is being initiated
- `connected`: Call is active and connected
- `onHold`: Call is on hold
- `ended`: Call has been terminated

## Usage

### 1. Initialization

Initialize the CallKit plugin in your app startup:

```dart
import 'package:talkliner/services/callkit_plugin.dart';

// In main.dart or app initialization
await CallKitPlugin.instance.initialize(
  appName: "Talkliner",
  supportsVideo: false,
  maxCallGroups: 1,
  maxCallsPerGroup: 1,
);
```

### 2. Set Up Event Listener

Listen for CallKit events:

```dart
await CallKitPlugin.instance.setEventListener((event) {
  final eventType = event['event'] as String;
  final callId = event['callId'] as String;
  
  switch (eventType) {
    case 'call_answered':
      // Handle call answered
      break;
    case 'call_ended':
      // Handle call ended
      break;
    case 'call_declined':
      // Handle call declined
      break;
  }
});
```

### 3. Show Incoming Call

Display an incoming call notification:

```dart
final success = await CallKitPlugin.instance.showIncomingCall(
  callId: "unique-call-id",
  callerName: "John Doe",
  callerNumber: "+1234567890",
  hasVideo: false,
  extraData: {
    'chat_id': 'chat-id',
    'user_id': 'user-id',
  },
);
```

### 4. Start Outgoing Call

Initiate an outgoing call:

```dart
final success = await CallKitPlugin.instance.startOutgoingCall(
  callId: "unique-call-id",
  calleeName: "Jane Smith",
  calleeNumber: "+0987654321",
  hasVideo: false,
  extraData: {
    'chat_id': 'chat-id',
    'user_id': 'user-id',
  },
);
```

### 5. Call Management

Manage active calls:

```dart
// End a call
await CallKitPlugin.instance.endCall(callId);

// Answer a call
await CallKitPlugin.instance.answerCall(callId);

// Decline a call
await CallKitPlugin.instance.declineCall(callId);

// Set call on hold
await CallKitPlugin.instance.setCallOnHold(callId, true);

// Mute a call
await CallKitPlugin.instance.setCallMuted(callId, true);

// Set speaker mode
await CallKitPlugin.instance.setCallSpeaker(callId, true);
```

### 6. Call State Queries

Get information about calls:

```dart
// Get specific call state
final callState = await CallKitPlugin.instance.getCallState(callId);

// Get all active calls
final activeCalls = await CallKitPlugin.instance.getActiveCalls();
```

## Integration with Existing Call System

The plugin integrates with the existing `CallService` to provide seamless call handling:

```dart
// In call_service.dart
Future<void> handleEvent(String event, Map<String, dynamic> data) async {
  switch (eventType) {
    case 'request':
      // Show incoming call using CallKit
      final success = await CallKitPlugin.instance.showIncomingCall(
        callId: chatId,
        callerName: user.displayName,
        callerNumber: null,
        hasVideo: false,
        extraData: {
          'chat_id': chatId,
          'user_id': user.id,
        },
      );
      
      if (!success) {
        // Fallback to existing UI
        AppNavigator.push('/incoming-call', {...});
      }
      break;
  }
}
```

## iOS Configuration

### Required Capabilities

Add the following capabilities to your iOS app:

1. **Voice over IP** (for VoIP push notifications)
2. **Background Modes** with "Voice over IP" enabled

### Info.plist Configuration

Ensure your `Info.plist` includes:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
</array>
```

### AppDelegate Integration

The `AppDelegate.swift` has been updated to integrate the CallKit handler:

```swift
private func setupCallKitHandler() {
    callKitHandler = CallKitHandler()
    callKitHandler?.setup(with: self.registrar(forPlugin: "CallKitPlugin")!)
}
```

## Event Types

The plugin sends the following events:

- `call_answered`: Call was answered through CallKit
- `call_ended`: Call was ended through CallKit
- `call_declined`: Call was declined through CallKit
- `call_hold_changed`: Call hold state changed
- `call_muted_changed`: Call mute state changed
- `call_started`: Outgoing call started
- `provider_reset`: CallKit provider was reset

## Error Handling

The plugin includes comprehensive error handling:

```dart
try {
  final success = await CallKitPlugin.instance.showIncomingCall(...);
  if (success) {
    print('Call shown successfully');
  } else {
    print('Failed to show call');
  }
} catch (e) {
  print('Error: $e');
  // Handle error appropriately
}
```

## Testing

Use the provided example (`lib/examples/callkit_usage_example.dart`) to test the plugin functionality:

```dart
// Navigate to the example screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CallKitUsageExample()),
);
```

## Troubleshooting

### Common Issues

1. **CallKit not showing calls**: Ensure CallKit is properly initialized and the app has the required capabilities.

2. **Events not received**: Check that the event listener is properly set up and not removed prematurely.

3. **Audio issues**: Verify that the audio session is properly configured in the iOS implementation.

4. **Permission issues**: Ensure the app has microphone permissions.

### Debug Information

Enable debug logging by checking the console output for CallKit-related messages:

```
CallKit Event: call_answered for call: call-id
CallKit initialize error: PlatformException
```

## Dependencies

The plugin uses the following Flutter packages:

- `flutter/services.dart` for method channels
- `dart:async` for event handling

No additional external dependencies are required.

## Platform Support

Currently, this plugin only supports iOS. Android support would require a separate implementation using Android's Telecom framework.

## Future Enhancements

Potential improvements:

1. **Video Call Support**: Extend to support video calls
2. **Group Call Support**: Add support for conference calls
3. **Call Recording**: Integrate call recording capabilities
4. **Call History**: Persistent call history storage
5. **Android Support**: Implement Android equivalent functionality

## License

This plugin is part of the Talkliner project and follows the same licensing terms. 