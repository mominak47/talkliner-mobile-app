# CallKit Integration with flutter_callkit_incoming

This document describes the CallKit integration implemented using the `flutter_callkit_incoming` package.

## Overview

The app now uses `flutter_callkit_incoming` instead of a custom CallKit implementation. This provides better reliability, easier maintenance, and proper iOS CallKit integration.

## Key Components

### 1. iOS AppDelegate Configuration

The `ios/Runner/AppDelegate.swift` has been updated with:

- **CallKit and PushKit imports**: Required for VoIP functionality
- **Audio session configuration**: Properly configured for voice calls
- **Background app handling**: Support for app termination and background modes
- **PushKit configuration**: Full VoIP push notification setup
- **PKPushRegistryDelegate**: Handles VoIP token and push notifications
- **Method channels**: Communication between native and Flutter for VoIP

### 2. iOS Entitlements

The `ios/Runner/RunnerDebug.entitlements` includes:

- `com.apple.developer.voip-push-notification`: For VoIP push notifications
- `com.apple.developer.push-to-talk`: For push-to-talk functionality
- `aps-environment`: For push notification environment

### 3. Info.plist Configuration

The `ios/Runner/Info.plist` includes:

- **Background modes**: `voip` and `remote-notification`
- **Privacy descriptions**: Microphone, camera, and location access
- **App Transport Security**: Secure network configuration

### 4. CallService Implementation

The `lib/services/call_service.dart` provides:

- **Incoming call display**: Using `FlutterCallkitIncoming.showCallkitIncoming()`
- **Call management**: Answer, decline, end, mute, hold calls
- **Event handling**: Listen to CallKit events
- **Integration testing**: Verify CallKit functionality

### 5. VoIP Push Service

The `lib/services/voip_push_service.dart` provides:

- **VoIP token management**: Receives and stores VoIP push tokens
- **Push notification handling**: Processes incoming VoIP push notifications
- **Method channel communication**: Bridges native PushKit with Flutter
- **Server integration**: Sends tokens to server for push notifications

## Usage

### Showing Incoming Calls

```dart
final params = CallKitParams(
  id: chatId,
  nameCaller: user.displayName,
  appName: 'Talkliner',
  avatar: 'https://i.pravatar.cc/100',
  handle: user.displayName,
  type: 1,
  duration: 30000,
  textAccept: 'Accept',
  textDecline: 'Decline',
  extra: <String, dynamic>{
    'chat_id': chatId,
    'user_id': user.id,
  },
  headers: <String, dynamic>{
    'apiKey': 'Abc@123!',
    'platform': 'flutter',
  },
);

await FlutterCallkitIncoming.showCallkitIncoming(params);
```

### Managing Calls

```dart
// End a call
await FlutterCallkitIncoming.endCall(callId);

// Mute a call
await FlutterCallkitIncoming.muteCall(callId, isMuted: true);

// Hold a call
await FlutterCallkitIncoming.holdCall(callId, isOnHold: true);

// Get active calls
final calls = await FlutterCallkitIncoming.activeCalls();
```

### Event Handling

```dart
FlutterCallkitIncoming.onEvent.listen((event) {
  switch (event.name) {
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

## Testing

The CallService includes automatic integration testing that:

1. Checks for active calls on initialization
2. Retrieves VoIP push token
3. Tests VoIP Push Service availability
4. Requests VoIP token if not available
5. Logs any integration errors

### VoIP Push Testing

The VoIP Push Service provides:

1. **Token Management**: Automatically receives VoIP push tokens
2. **Push Handling**: Processes incoming VoIP push notifications
3. **Integration**: Seamlessly integrates with existing CallService
4. **Debugging**: Comprehensive logging for troubleshooting

## Benefits

1. **Reliability**: Well-maintained package with community support
2. **Cross-platform**: Works on both iOS and Android
3. **Proper iOS Integration**: Handles CallKit automatically
4. **Background Support**: Works when app is terminated
5. **Rich API**: Supports all CallKit features

## Troubleshooting

### Common Issues

1. **CallKit not showing**: Check entitlements and background modes
2. **Audio issues**: Verify audio session configuration
3. **Background not working**: Ensure proper background modes in Info.plist

### Debug Information

The CallService logs detailed information about:
- CallKit events
- Integration test results
- Error messages
- Active calls status

The VoIP Push Service logs:
- VoIP token reception
- Push notification processing
- Method channel communication
- Server token updates

## References

- [flutter_callkit_incoming GitHub](https://github.com/hiennguyen92/flutter_callkit_incoming)
- [iOS CallKit Documentation](https://developer.apple.com/documentation/callkit)
- [VoIP Push Notifications](https://developer.apple.com/documentation/pushkit) 