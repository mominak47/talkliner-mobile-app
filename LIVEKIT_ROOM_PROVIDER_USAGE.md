# LiveKit Room Provider Usage Guide

This document provides comprehensive documentation for using the integrated LiveKit room provider in the Talkliner app.

## Overview

The `room_provider.dart` file integrates LiveKitService functionality with Riverpod state management, providing a robust solution for managing LiveKit video/audio calls with proper state management, error handling, and participant management.

## Table of Contents

1. [Providers](#providers)
2. [Basic Usage](#basic-usage)
3. [Room Connection](#room-connection)
4. [Media Controls](#media-controls)
5. [Participant Management](#participant-management)
6. [State Management](#state-management)
7. [Error Handling](#error-handling)
8. [Complete Examples](#complete-examples)
9. [Best Practices](#best-practices)

## Providers

### Core Providers

```dart
// Main room provider - manages the LiveKit Room instance
final roomProvider = StateNotifierProvider<RoomNotifier, Room?>((ref) {
  return RoomNotifier();
});

// Room state provider - tracks connection status and metadata
final roomStateProvider = StateNotifierProvider<RoomStateNotifier, RoomState>((ref) {
  return RoomStateNotifier();
});
```

### Convenience Providers

```dart
// Check if currently connected to a room
final isConnectedProvider = Provider<bool>((ref) {
  final roomNotifier = ref.watch(roomProvider.notifier);
  return roomNotifier.isConnected;
});

// Access local participant
final localParticipantProvider = Provider<LocalParticipant?>((ref) {
  final roomNotifier = ref.watch(roomProvider.notifier);
  return roomNotifier.localParticipant;
});

// Access remote participants
final remoteParticipantsProvider = Provider<Map<String, RemoteParticipant>>((ref) {
  final roomNotifier = ref.watch(roomProvider.notifier);
  return roomNotifier.remoteParticipants;
});

// Get detailed connection status
final roomConnectionStatusProvider = Provider<RoomConnectionStatus>((ref) {
  final room = ref.watch(roomProvider);
  if (room == null) return RoomConnectionStatus.disconnected();
  
  return RoomConnectionStatus(
    isConnecting: room.connectionState == ConnectionState.connecting,
    isConnected: room.connectionState == ConnectionState.connected,
    isReconnecting: room.connectionState == ConnectionState.reconnecting,
    hasError: room.connectionState == ConnectionState.disconnected,
    errorMessage: null,
  );
});
```

## Basic Usage

### 1. Import the Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talkliner/providers/room_provider.dart';
```

### 2. Access in Widgets

```dart
class VideoCallScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the room state
    final room = ref.watch(roomProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final connectionStatus = ref.watch(roomConnectionStatusProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Show connection status
          Text('Status: ${connectionStatus.isConnected ? "Connected" : "Disconnected"}'),
          
          // Show room info
          if (room != null) ...[
            Text('Room: ${room.name}'),
            Text('Participants: ${room.participants.length}'),
          ],
          
          // Action buttons
          ElevatedButton(
            onPressed: () => _connectToRoom(ref),
            child: Text('Connect'),
          ),
          
          ElevatedButton(
            onPressed: () => _disconnectFromRoom(ref),
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
```

## Room Connection

### Connect to a Room

```dart
Future<void> _connectToRoom(WidgetRef ref) async {
  try {
    final roomNotifier = ref.read(roomProvider.notifier);
    
    // Define room options
    final roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      stopLocalTrackOnUnpublish: true,
    );
    
    // Connect to room
    await roomNotifier.connectToRoom(
      chatId: 'chat_123',
      roomOptions: roomOptions,
      onRoomEvent: (room) {
        // Handle room events
        print('Room event: ${room.name}');
      },
    );
    
    print('Successfully connected to room');
  } catch (e) {
    print('Failed to connect: $e');
  }
}
```

### Simple Connection (Backward Compatible)

```dart
Future<void> _simpleConnect(WidgetRef ref) async {
  try {
    final roomNotifier = ref.read(roomProvider.notifier);
    
    // Get token from your server
    final token = await roomNotifier.getToken('chat_123');
    
    // Connect using URL and token
    await roomNotifier.connect(
      'wss://your-livekit-server.com',
      token,
    );
  } catch (e) {
    print('Connection failed: $e');
  }
}
```

### Disconnect from Room

```dart
Future<void> _disconnectFromRoom(WidgetRef ref) async {
  try {
    final roomNotifier = ref.read(roomProvider.notifier);
    await roomNotifier.disconnect();
    print('Disconnected from room');
  } catch (e) {
    print('Disconnect failed: $e');
  }
}
```

## Media Controls

### Camera Controls

```dart
class CameraControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localParticipant = ref.watch(localParticipantProvider);
    
    return Row(
      children: [
        // Enable camera
        ElevatedButton(
          onPressed: () async {
            final roomNotifier = ref.read(roomProvider.notifier);
            await roomNotifier.enableCameraAndMicrophone();
          },
          child: Text('Enable Camera'),
        ),
        
        // Toggle camera
        ElevatedButton(
          onPressed: () async {
            final roomNotifier = ref.read(roomProvider.notifier);
            await roomNotifier.toggleCamera();
          },
          child: Text('Toggle Camera'),
        ),
        
        // Disable camera
        ElevatedButton(
          onPressed: () async {
            final roomNotifier = ref.read(roomProvider.notifier);
            await roomNotifier.disableCameraAndMicrophone();
          },
          child: Text('Disable Camera'),
        ),
      ],
    );
  }
}
```

### Microphone Controls

```dart
class MicrophoneControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Toggle microphone
        ElevatedButton(
          onPressed: () async {
            final roomNotifier = ref.read(roomProvider.notifier);
            await roomNotifier.toggleMicrophone();
          },
          child: Text('Toggle Mic'),
        ),
        
        // Check microphone status
        Consumer(
          builder: (context, ref, child) {
            final localParticipant = ref.watch(localParticipantProvider);
            final isMicEnabled = (localParticipant?.isMicrophoneEnabled as bool?) ?? false;
            
            return Text('Mic: ${isMicEnabled ? "ON" : "OFF"}');
          },
        ),
      ],
    );
  }
}
```

## Participant Management

### Access Participants

```dart
class ParticipantsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localParticipant = ref.watch(localParticipantProvider);
    final remoteParticipants = ref.watch(remoteParticipantsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Local participant
        if (localParticipant != null) ...[
          Text('You (Local)', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Camera: ${(localParticipant.isCameraEnabled as bool?) ?? false ? "ON" : "OFF"}'),
          Text('Microphone: ${(localParticipant.isMicrophoneEnabled as bool?) ?? false ? "ON" : "OFF"}'),
          SizedBox(height: 16),
        ],
        
        // Remote participants
        if (remoteParticipants.isNotEmpty) ...[
          Text('Remote Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...remoteParticipants.values.map((participant) => 
            ListTile(
              title: Text(participant.identity),
              subtitle: Text('Camera: ${(participant.isCameraEnabled as bool?) ?? false ? "ON" : "OFF"}'),
            ),
          ),
        ],
      ],
    );
  }
}
```

### Monitor Participant Changes

```dart
class ParticipantMonitor extends ConsumerStatefulWidget {
  @override
  ConsumerState<ParticipantMonitor> createState() => _ParticipantMonitorState();
}

class _ParticipantMonitorState extends ConsumerState<ParticipantMonitor> {
  @override
  void initState() {
    super.initState();
    
    // Listen to room changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final room = ref.read(roomProvider);
      if (room != null) {
        room.addListener(_onRoomUpdate);
      }
    });
  }
  
  void _onRoomUpdate() {
    // This will be called whenever the room state changes
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomProvider);
    final participants = room?.participants ?? {};
    
    return ListView.builder(
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants.values.elementAt(index);
        return ListTile(
          title: Text(participant.identity),
          subtitle: Text('Camera: ${(participant.isCameraEnabled as bool?) ?? false ? "ON" : "OFF"}'),
        );
      },
    );
  }
}
```

## State Management

### Room State Tracking

```dart
class RoomStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(roomStateProvider);
    final connectionStatus = ref.watch(roomConnectionStatusProvider);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room Status', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 8),
            
            // Connection status
            Text('Connecting: ${connectionStatus.isConnecting}'),
            Text('Connected: ${connectionStatus.isConnected}'),
            Text('Reconnecting: ${connectionStatus.isReconnecting}'),
            Text('Has Error: ${connectionStatus.hasError}'),
            
            if (connectionStatus.errorMessage != null)
              Text('Error: ${connectionStatus.errorMessage}'),
            
            SizedBox(height: 16),
            
            // Room state
            Text('Room State', style: Theme.of(context).textTheme.subtitle1),
            Text('Connecting: ${roomState.isConnecting}'),
            Text('Connected: ${roomState.isConnected}'),
            Text('Has Error: ${roomState.hasError}'),
            
            if (roomState.currentChatId != null)
              Text('Chat ID: ${roomState.currentChatId}'),
          ],
        ),
      ),
    );
  }
}
```

### Manual State Updates

```dart
class RoomStateController extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            final stateNotifier = ref.read(roomStateProvider.notifier);
            stateNotifier.setConnecting('chat_123');
          },
          child: Text('Set Connecting'),
        ),
        
        ElevatedButton(
          onPressed: () {
            final stateNotifier = ref.read(roomStateProvider.notifier);
            stateNotifier.setConnected();
          },
          child: Text('Set Connected'),
        ),
        
        ElevatedButton(
          onPressed: () {
            final stateNotifier = ref.read(roomStateProvider.notifier);
            stateNotifier.setError('Connection failed');
          },
          child: Text('Set Error'),
        ),
        
        ElevatedButton(
          onPressed: () {
            final stateNotifier = ref.read(roomStateProvider.notifier);
            stateNotifier.reset();
          },
          child: Text('Reset State'),
        ),
      ],
    );
  }
}
```

## Error Handling

### Try-Catch Pattern

```dart
Future<void> _safeRoomOperation(WidgetRef ref) async {
  try {
    final roomNotifier = ref.read(roomProvider.notifier);
    
    // Attempt room operation
    await roomNotifier.connectToRoom(
      chatId: 'chat_123',
      roomOptions: RoomOptions(),
      onRoomEvent: (room) {},
    );
    
    // Success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully connected to room')),
    );
    
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to connect: $e'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Log error
    LogManager.add('Room connection error: $e');
  }
}
```

### Error State Monitoring

```dart
class ErrorMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(roomConnectionStatusProvider);
    final roomState = ref.watch(roomStateProvider);
    
    // Show error if any
    if (connectionStatus.hasError || roomState.hasError) {
      return Card(
        color: Colors.red[100],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(height: 8),
              Text(
                'Connection Error',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (connectionStatus.errorMessage != null)
                Text(connectionStatus.errorMessage!),
              if (roomState.errorMessage != null)
                Text(roomState.errorMessage!),
            ],
          ),
        ),
      );
    }
    
    return SizedBox.shrink();
  }
}
```

## Complete Examples

### Video Call Screen

```dart
class VideoCallScreen extends ConsumerStatefulWidget {
  final String chatId;
  
  const VideoCallScreen({Key? key, required this.chatId}) : super(key: key);
  
  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }
  
  Future<void> _connectToRoom() async {
    try {
      final roomNotifier = ref.read(roomProvider.notifier);
      
      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        stopLocalTrackOnUnpublish: true,
      );
      
      await roomNotifier.connectToRoom(
        chatId: widget.chatId,
        roomOptions: roomOptions,
        onRoomEvent: (room) {
          print('Connected to room: ${room.name}');
        },
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomProvider);
    final isConnected = ref.watch(isConnectedProvider);
    final localParticipant = ref.watch(localParticipantProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
        actions: [
          IconButton(
            icon: Icon(Icons.call_end),
            onPressed: () async {
              final roomNotifier = ref.read(roomProvider.notifier);
              await roomNotifier.disconnect();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: EdgeInsets.all(16),
            color: isConnected ? Colors.green[100] : Colors.red[100],
            child: Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
          // Media controls
          if (isConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final roomNotifier = ref.read(roomProvider.notifier);
                    await roomNotifier.toggleCamera();
                  },
                  child: Text('Toggle Camera'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final roomNotifier = ref.read(roomProvider.notifier);
                    await roomNotifier.toggleMicrophone();
                  },
                  child: Text('Toggle Mic'),
                ),
              ],
            ),
          ],
          
          // Video views
          if (isConnected && room != null) ...[
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  // Local video
                  if (localParticipant != null)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Text('Local Video'),
                      ),
                    ),
                  
                  // Remote videos
                  ...room.remoteParticipants.values.map((participant) =>
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                      ),
                      child: Center(
                        child: Text('${participant.identity}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Disconnect when leaving
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomNotifier = ref.read(roomProvider.notifier);
      roomNotifier.disconnect();
    });
    super.dispose();
  }
}
```

### Audio Call Screen

```dart
class AudioCallScreen extends ConsumerStatefulWidget {
  final String chatId;
  
  const AudioCallScreen({Key? key, required this.chatId}) : super(key: key);
  
  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }
  
  Future<void> _connectToRoom() async {
    try {
      final roomNotifier = ref.read(roomProvider.notifier);
      
      final roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        stopLocalTrackOnUnpublish: true,
      );
      
      await roomNotifier.connectToRoom(
        chatId: widget.chatId,
        roomOptions: roomOptions,
        onRoomEvent: (room) {
          // Enable microphone for audio calls
          roomNotifier.enableCameraAndMicrophone();
        },
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isConnectedProvider);
    final localParticipant = ref.watch(localParticipantProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Call'),
        actions: [
          IconButton(
            icon: Icon(Icons.call_end),
            onPressed: () async {
              final roomNotifier = ref.read(roomProvider.notifier);
              await roomNotifier.disconnect();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call,
              size: 100,
              color: isConnected ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 32),
            Text(
              isConnected ? 'Connected' : 'Connecting...',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 16),
            Text('Chat ID: ${widget.chatId}'),
            
            if (isConnected) ...[
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final roomNotifier = ref.read(roomProvider.notifier);
                      await roomNotifier.toggleMicrophone();
                    },
                    child: Text('Toggle Mic'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final roomNotifier = ref.read(roomProvider.notifier);
                      await roomNotifier.toggleCamera();
                    },
                    child: Text('Toggle Camera'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomNotifier = ref.read(roomProvider.notifier);
      roomNotifier.disconnect();
    });
    super.dispose();
  }
}
```

## Best Practices

### 1. Error Handling

- Always wrap room operations in try-catch blocks
- Use the error state providers to show user-friendly error messages
- Log errors for debugging purposes

### 2. State Management

- Use the appropriate providers for different types of data
- Avoid directly accessing the room notifier unless necessary
- Listen to state changes to update UI accordingly

### 3. Resource Management

- Always disconnect from rooms when leaving screens
- Dispose of listeners properly
- Handle connection state changes gracefully

### 4. Performance

- Use `ref.watch()` for reactive data that should trigger rebuilds
- Use `ref.read()` for one-time operations
- Avoid unnecessary rebuilds by watching only the data you need

### 5. User Experience

- Show loading states during connection
- Provide clear feedback for user actions
- Handle edge cases gracefully (network issues, permissions, etc.)

### 6. Testing

- Test different connection scenarios
- Verify error handling works correctly
- Test media controls in various states

## Troubleshooting

### Common Issues

1. **Connection Fails**: Check token validity and server URL
2. **Media Not Working**: Verify camera/microphone permissions
3. **State Not Updating**: Ensure proper provider usage
4. **Memory Leaks**: Check dispose methods and listener cleanup

### Debug Tips

- Use `LogManager.add()` for debugging
- Monitor the room state providers
- Check LiveKit server logs
- Verify network connectivity

## Conclusion

The integrated LiveKit room provider provides a comprehensive solution for managing video/audio calls in the Talkliner app. By following this documentation and best practices, you can create robust, user-friendly calling experiences with proper error handling and state management.

For additional information, refer to:
- [LiveKit Client Documentation](https://docs.livekit.io/reference/client-sdk/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter State Management Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
