# MediaSoup WebRTC Backend Documentation

This document provides comprehensive documentation for the MediaSoup WebRTC backend integration, designed to help Flutter developers understand and integrate with the audio/video calling system.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [API Endpoints](#api-endpoints)
4. [Socket.io Events](#socketio-events)
5. [Flutter Integration Guide](#flutter-integration-guide)
6. [Configuration](#configuration)
7. [Error Handling](#error-handling)
8. [Testing](#testing)

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Socket.io     │    │   MediaSoup     │
│                 │◄──►│   Backend       │◄──►│   Service       │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   FFmpeg        │
                       │   Recording     │
                       └─────────────────┘
```

### Key Components

- **MediaSoup Workers**: Handle WebRTC media processing
- **Room Manager**: Manages rooms and participants
- **Recording Manager**: Handles audio/video recording
- **Socket Handler**: Real-time communication
- **REST API**: HTTP endpoints for management

## Core Components

### 1. Worker Manager (`worker-manager.js`)

Manages MediaSoup workers that handle WebRTC media processing.

**Key Functions:**
- `initialize(numWorkers)`: Creates MediaSoup workers
- `getNextWorker()`: Returns next available worker (round-robin)
- `getStats()`: Returns worker statistics
- `close()`: Gracefully shuts down all workers

**Usage:**
```javascript
const workerManager = require('./worker-manager');
await workerManager.initialize(2); // Create 2 workers
const worker = workerManager.getNextWorker();
```

### 2. Room Manager (`room-manager.js`)

Manages WebRTC rooms, participants, and media streams.

**Key Functions:**
- `createRoom(roomId, options)`: Creates a new room
- `addParticipant(roomId, participantId, data)`: Adds participant to room
- `removeParticipant(roomId, participantId)`: Removes participant
- `startRecording(roomId, options)`: Starts recording
- `stopRecording(roomId)`: Stops recording

**Room Object Structure:**
```javascript
{
  id: "room-123",
  router: MediaSoupRouter,
  participants: Map<participantId, Participant>,
  options: {
    maxParticipants: 10,
    enableRecording: true,
    timeout: 0
  },
  recording: RecordingObject,
  stats: {
    audioProducers: 0,
    videoProducers: 0,
    audioConsumers: 0,
    videoConsumers: 0
  }
}
```

**Participant Object Structure:**
```javascript
{
  id: "user-123",
  roomId: "room-123",
  transports: Map<transportId, Transport>,
  producers: Map<producerId, Producer>,
  consumers: Map<consumerId, Consumer>,
  data: {
    name: "John Doe",
    avatar: "https://..."
  },
  joinedAt: timestamp,
  stats: {
    audioProducer: "producer-id",
    videoProducer: "producer-id",
    audioConsumers: ["consumer-id"],
    videoConsumers: ["consumer-id"]
  }
}
```

### 3. Recording Manager (`recording-manager.js`)

Handles audio and video recording using FFmpeg.

**Key Functions:**
- `startRecording(room, options)`: Starts recording for a room
- `stopRecording(recording)`: Stops recording
- `listRecordedFiles()`: Lists all recorded files
- `deleteRecordedFile(filename)`: Deletes a recorded file

**Recording Object Structure:**
```javascript
{
  id: "recording-123",
  roomId: "room-123",
  filename: "room_123_2024-01-01T12:00:00",
  startedAt: timestamp,
  options: {
    audio: { codec: "opus", bitrate: 64000 },
    video: { codec: "libx264", bitrate: "1000k" },
    format: "mp4"
  },
  files: {
    audio: "/path/to/audio.opus",
    video: "/path/to/video.h264",
    combined: "/path/to/combined.mp4"
  }
}
```

### 4. Socket Handler (`socket-handler.js`)

Handles real-time WebSocket communication for WebRTC signaling.

**Key Events:**
- Room management: create, join, leave
- Transport management: create, connect
- Producer management: create, close
- Consumer management: create, close, resume, pause
- Recording: start, stop

### 5. Configuration (`config.js`)

Centralized configuration for all MediaSoup settings.

**Key Settings:**
```javascript
{
  worker: {
    logLevel: "warn",
    rtcMinPort: 10000,
    rtcMaxPort: 10100
  },
  router: {
    mediaCodecs: [
      // Audio: Opus
      { kind: "audio", mimeType: "audio/opus", clockRate: 48000, channels: 2 },
      // Video: VP8, H264
      { kind: "video", mimeType: "video/VP8", clockRate: 90000 },
      { kind: "video", mimeType: "video/H264", clockRate: 90000 }
    ]
  },
  webRtcTransport: {
    listenIps: [{ ip: "127.0.0.1", announcedIp: "127.0.0.1" }],
    initialAvailableOutgoingBitrate: 1000000,
    minimumAvailableOutgoingBitrate: 600000
  },
  recording: {
    outputDir: "./recordings",
    audio: { codec: "opus", sampleRate: 48000, channels: 2, bitrate: 64000 },
    video: { codec: "libx264", bitrate: "1000k", framerate: 30, resolution: "1280x720" },
    format: "mp4"
  },
  room: {
    maxParticipants: 10,
    timeout: 0,
    enableRecording: true
  }
}
```

## API Endpoints

### Health & Status

#### GET `/api/mediasoup/health`
Check service health and status.

**Response:**
```json
{
  "success": true,
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "workers": {
    "totalWorkers": 2,
    "workers": [
      {
        "index": 0,
        "pid": 12345,
        "resourceUsage": { "cpu": 0.5, "memory": 512 }
      }
    ]
  },
  "rooms": {
    "totalRooms": 5,
    "totalParticipants": 12,
    "rooms": [...]
  }
}
```

#### GET `/api/mediasoup/stats`
Get comprehensive statistics.

**Response:**
```json
{
  "success": true,
  "stats": {
    "workers": { "totalWorkers": 2, "workers": [...] },
    "rooms": { "totalRooms": 5, "totalParticipants": 12 },
    "recordings": { "activeRecordings": 2, "recordings": [...] },
    "timestamp": "2024-01-01T12:00:00.000Z"
  }
}
```

### Room Management

#### POST `/api/mediasoup/rooms`
Create a new room.

**Request:**
```json
{
  "roomId": "room-123",
  "options": {
    "maxParticipants": 2,
    "enableRecording": true,
    "timeout": 3600000
  }
}
```

**Response:**
```json
{
  "success": true,
  "room": {
    "id": "room-123",
    "rtpCapabilities": { "codecs": [...], "headerExtensions": [...] },
    "options": { "maxParticipants": 2, "enableRecording": true },
    "createdAt": 1704110400000
  }
}
```

#### GET `/api/mediasoup/rooms`
List all rooms.

**Response:**
```json
{
  "success": true,
  "rooms": [
    {
      "id": "room-123",
      "participants": 2,
      "maxParticipants": 10,
      "createdAt": 1704110400000,
      "uptime": 3600000,
      "recording": {
        "isRecording": true,
        "startedAt": 1704110400000,
        "duration": 1800000
      },
      "stats": {
        "audioProducers": 2,
        "videoProducers": 2,
        "audioConsumers": 4,
        "videoConsumers": 4
      }
    }
  ]
}
```

#### GET `/api/mediasoup/rooms/:roomId`
Get room information.

**Response:**
```json
{
  "success": true,
  "room": {
    "id": "room-123",
    "rtpCapabilities": { "codecs": [...], "headerExtensions": [...] },
    "participants": [
      {
        "id": "user-123",
        "data": { "name": "John Doe" },
        "joinedAt": 1704110400000
      }
    ],
    "options": { "maxParticipants": 2, "enableRecording": true },
    "stats": { "audioProducers": 2, "videoProducers": 2 }
  }
}
```

#### DELETE `/api/mediasoup/rooms/:roomId`
Close a room.

**Response:**
```json
{
  "success": true,
  "message": "Room room-123 closed successfully"
}
```

### Participant Management

#### POST `/api/mediasoup/rooms/:roomId/participants`
Add a participant to a room.

**Request:**
```json
{
  "participantId": "user-123",
  "participantData": {
    "name": "John Doe",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

**Response:**
```json
{
  "success": true,
  "participant": {
    "id": "user-123",
    "roomId": "room-123",
    "data": { "name": "John Doe", "avatar": "https://..." },
    "joinedAt": 1704110400000
  }
}
```

#### GET `/api/mediasoup/rooms/:roomId/participants`
List all participants in a room.

**Response:**
```json
{
  "success": true,
  "participants": [
    {
      "id": "user-123",
      "data": { "name": "John Doe" },
      "joinedAt": 1704110400000,
      "stats": {
        "audioProducer": "producer-123",
        "videoProducer": "producer-456",
        "audioConsumers": ["consumer-123"],
        "videoConsumers": ["consumer-456"]
      }
    }
  ]
}
```

#### DELETE `/api/mediasoup/rooms/:roomId/participants/:participantId`
Remove a participant from a room.

**Response:**
```json
{
  "success": true,
  "message": "Participant user-123 removed from room room-123"
}
```

### Recording Management

#### POST `/api/mediasoup/rooms/:roomId/recording/start`
Start recording for a room.

**Request:**
```json
{
  "options": {
    "audio": { "bitrate": 64000 },
    "video": { "bitrate": "1000k", "resolution": "1280x720" }
  }
}
```

**Response:**
```json
{
  "success": true,
  "recording": {
    "id": "recording-123",
    "roomId": "room-123",
    "startedAt": 1704110400000,
    "options": {
      "audio": { "bitrate": 64000 },
      "video": { "bitrate": "1000k" }
    }
  }
}
```

#### POST `/api/mediasoup/rooms/:roomId/recording/stop`
Stop recording for a room.

**Response:**
```json
{
  "success": true,
  "recording": {
    "id": "recording-123",
    "roomId": "room-123",
    "duration": 1800000,
    "files": {
      "audio": "/recordings/room_123_audio.opus",
      "video": "/recordings/room_123_video.h264",
      "combined": "/recordings/room_123_combined.mp4"
    },
    "startedAt": 1704110400000,
    "stoppedAt": 1704112200000
  }
}
```

#### GET `/api/mediasoup/rooms/:roomId/recording/status`
Get recording status for a room.

**Response:**
```json
{
  "success": true,
  "recording": {
    "isRecording": true,
    "id": "recording-123",
    "startedAt": 1704110400000,
    "duration": 1800000,
    "options": {
      "audio": { "bitrate": 64000 },
      "video": { "bitrate": "1000k" }
    }
  }
}
```

#### GET `/api/mediasoup/recordings`
List all recorded files.

**Response:**
```json
{
  "success": true,
  "files": [
    {
      "name": "room_123_combined.mp4",
      "path": "/recordings/room_123_combined.mp4",
      "size": 52428800,
      "created": "2024-01-01T12:00:00.000Z",
      "modified": "2024-01-01T12:30:00.000Z"
    }
  ]
}
```

#### DELETE `/api/mediasoup/recordings/:filename`
Delete a recorded file.

**Response:**
```json
{
  "success": true,
  "message": "File room_123_combined.mp4 deleted successfully"
}
```

## Socket.io Events

### Client to Server Events

#### Room Management
```javascript
// Create room
socket.emit('mediasoup:create-room', {
  roomId: 'room-123',
  options: { maxParticipants: 2, enableRecording: true }
});

// Join room
socket.emit('mediasoup:join-room', {
  roomId: 'room-123',
  participantData: { name: 'John Doe' }
});

// Leave room
socket.emit('mediasoup:leave-room', { roomId: 'room-123' });

// Get room info
socket.emit('mediasoup:get-room-info', { roomId: 'room-123' });
```

#### Transport Management
```javascript
// Create transport
socket.emit('mediasoup:create-transport', {
  roomId: 'room-123',
  direction: 'send' // or 'recv'
});

// Connect transport
socket.emit('mediasoup:connect-transport', {
  roomId: 'room-123',
  transportId: 'transport-123',
  dtlsParameters: { /* DTLS parameters */ }
});
```

#### Producer Management
```javascript
// Create producer
socket.emit('mediasoup:create-producer', {
  roomId: 'room-123',
  transportId: 'transport-123',
  kind: 'audio', // or 'video'
  rtpParameters: { /* RTP parameters */ }
});

// Close producer
socket.emit('mediasoup:close-producer', {
  roomId: 'room-123',
  producerId: 'producer-123'
});
```

#### Consumer Management
```javascript
// Create consumer
socket.emit('mediasoup:create-consumer', {
  roomId: 'room-123',
  transportId: 'transport-123',
  producerId: 'producer-123',
  rtpCapabilities: { /* RTP capabilities */ }
});

// Close consumer
socket.emit('mediasoup:close-consumer', {
  roomId: 'room-123',
  consumerId: 'consumer-123'
});

// Resume consumer
socket.emit('mediasoup:resume-consumer', {
  roomId: 'room-123',
  consumerId: 'consumer-123'
});

// Pause consumer
socket.emit('mediasoup:pause-consumer', {
  roomId: 'room-123',
  consumerId: 'consumer-123'
});
```

#### Recording
```javascript
// Start recording
socket.emit('mediasoup:start-recording', {
  roomId: 'room-123',
  options: {
    audio: { bitrate: 64000 },
    video: { bitrate: '1000k' }
  }
});

// Stop recording
socket.emit('mediasoup:stop-recording', { roomId: 'room-123' });
```

### Server to Client Events

#### Room Events
```javascript
// Room created
socket.on('mediasoup:room-created', (data) => {
  console.log('Room created:', data.room.id);
});

// Room joined
socket.on('mediasoup:room-joined', (data) => {
  console.log('Joined room:', data.room.id);
  console.log('Participants:', data.room.participants);
});

// Room left
socket.on('mediasoup:room-left', (data) => {
  console.log('Left room:', data.roomId);
});

// Participant joined
socket.on('mediasoup:participant-joined', (data) => {
  console.log('New participant:', data.participant.id);
});

// Participant left
socket.on('mediasoup:participant-left', (data) => {
  console.log('Participant left:', data.participantId);
});
```

#### Transport Events
```javascript
// Transport created
socket.on('mediasoup:transport-created', (data) => {
  console.log('Transport created:', data.transport.id);
  // Use data.transport for WebRTC setup
});

// Transport connected
socket.on('mediasoup:transport-connected', (data) => {
  console.log('Transport connected:', data.transportId);
});
```

#### Producer Events
```javascript
// Producer created
socket.on('mediasoup:producer-created', (data) => {
  console.log('Producer created:', data.producer.id);
});

// New producer (from other participant)
socket.on('mediasoup:new-producer', (data) => {
  console.log('New producer:', data.producer.id);
  // Create consumer for this producer
});

// Producer closed
socket.on('mediasoup:producer-closed', (data) => {
  console.log('Producer closed:', data.producerId);
});
```

#### Consumer Events
```javascript
// Consumer created
socket.on('mediasoup:consumer-created', (data) => {
  console.log('Consumer created:', data.consumer.id);
  // Use data.consumer for remote stream setup
});

// Consumer closed
socket.on('mediasoup:consumer-closed', (data) => {
  console.log('Consumer closed:', data.consumerId);
});

// Consumer resumed
socket.on('mediasoup:consumer-resumed', (data) => {
  console.log('Consumer resumed:', data.consumerId);
});

// Consumer paused
socket.on('mediasoup:consumer-paused', (data) => {
  console.log('Consumer paused:', data.consumerId);
});
```

#### Recording Events
```javascript
// Recording started
socket.on('mediasoup:recording-started', (data) => {
  console.log('Recording started:', data.recording.id);
});

// Recording stopped
socket.on('mediasoup:recording-stopped', (data) => {
  console.log('Recording stopped:', data.recording.id);
  console.log('Duration:', data.recording.duration);
  console.log('Files:', data.recording.files);
});
```

## Flutter Integration Guide

### 1. Dependencies

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_webrtc: ^0.9.47
  socket_io_client: ^2.0.3+1
  http: ^1.1.0
  permission_handler: ^11.0.1
```

### 2. Basic Integration Flow

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MediaSoupClient {
  IO.Socket? socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  // Connect to server
  Future<void> connect(String serverUrl, String authToken) async {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {'token': authToken},
    });
    
    _setupSocketListeners();
    socket!.connect();
  }

  // Create room for 1-to-1 call
  Future<String> createRoom() async {
    final roomId = DateTime.now().millisecondsSinceEpoch.toString();
    
    socket!.emit('mediasoup:create-room', {
      'roomId': roomId,
      'options': {
        'maxParticipants': 2, // 1-to-1 call
        'enableRecording': true,
      }
    });

    return roomId;
  }

  // Join room
  Future<void> joinRoom(String roomId, Map<String, dynamic> participantData) async {
    socket!.emit('mediasoup:join-room', {
      'roomId': roomId,
      'participantData': participantData,
    });
  }

  // Setup socket event listeners
  void _setupSocketListeners() {
    socket!.onConnect((_) => print('Connected to server'));
    socket!.onDisconnect((_) => print('Disconnected from server'));
    
    // Handle room events
    socket!.on('mediasoup:room-created', (data) {
      print('Room created:', data['room']['id']);
    });
    
    socket!.on('mediasoup:room-joined', (data) {
      print('Joined room:', data['room']['id']);
    });
    
    // Handle transport events
    socket!.on('mediasoup:transport-created', (data) {
      print('Transport created:', data['transport']['id']);
    });
    
    // Handle producer events
    socket!.on('mediasoup:producer-created', (data) {
      print('Producer created:', data['producer']['id']);
    });
    
    // Handle consumer events
    socket!.on('mediasoup:consumer-created', (data) {
      print('Consumer created:', data['consumer']['id']);
      _setupRemoteStream(data['consumer']);
    });
  }

  // Setup remote stream
  void _setupRemoteStream(Map<String, dynamic> consumer) {
    // Implementation depends on your WebRTC setup
    // This is where you'd attach the remote stream to your UI
  }

  // Start recording
  Future<void> startRecording(String roomId) async {
    socket!.emit('mediasoup:start-recording', {
      'roomId': roomId,
      'options': {
        'audio': {'bitrate': 64000},
        'video': {'bitrate': '1000k'},
      }
    });
  }

  // Stop recording
  Future<void> stopRecording(String roomId) async {
    socket!.emit('mediasoup:stop-recording', {'roomId': roomId});
  }
}
```

### 3. Usage Example

```dart
void main() async {
  final client = MediaSoupClient();
  
  // Connect to server
  await client.connect('ws://your-server:3000/ws', 'your-jwt-token');
  
  // Create room for 1-to-1 call
  final roomId = await client.createRoom();
  print('Created room: $roomId');
  
  // Join room
  await client.joinRoom(roomId, {
    'name': 'Flutter User',
    'platform': 'flutter',
  });
  
  // Start recording
  await client.startRecording(roomId);
}
```

## Configuration

### Environment Variables

Add to your `.env` file:
```env
# MediaSoup Configuration
MEDIASOUP_LISTEN_IP=127.0.0.1
MEDIASOUP_ANNOUNCED_IP=127.0.0.1
MEDIASOUP_WORKERS=1

# Recording Configuration
RECORDING_OUTPUT_DIR=./recordings
```

### Server Configuration

The server automatically initializes MediaSoup when it starts:

```javascript
// In src/index.js
const mediaSoupService = require('./mediasoup');

// Initialize MediaSoup with socket.io integration
await mediaSoupService.initialize({
  numWorkers: process.env.MEDIASOUP_WORKERS || 1,
  io: io
});
```

## Error Handling

### Common Error Responses

```json
{
  "success": false,
  "error": "Room not found"
}
```

### Error Types

- **Room not found**: Room doesn't exist
- **Room is full**: Maximum participants reached
- **Participant not found**: Participant doesn't exist in room
- **Transport not found**: WebRTC transport doesn't exist
- **Producer not found**: Media producer doesn't exist
- **Consumer not found**: Media consumer doesn't exist
- **Recording already in progress**: Recording already active
- **No recording in progress**: No active recording to stop

### Socket.io Error Handling

```javascript
socket.on('connect_error', (error) => {
  console.error('Connection error:', error);
});

socket.on('error', (error) => {
  console.error('Socket error:', error);
});
```

## Testing

### 1. Health Check

```bash
curl http://localhost:3000/api/mediasoup/health
```

### 2. Create Room

```bash
curl -X POST http://localhost:3000/api/mediasoup/rooms \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": "test-room-123",
    "options": {
      "maxParticipants": 2,
      "enableRecording": true
    }
  }'
```

### 3. List Rooms

```bash
curl http://localhost:3000/api/mediasoup/rooms
```

### 4. Get Statistics

```bash
curl http://localhost:3000/api/mediasoup/stats
```

### 5. Test with Browser Client

Use the included `example-client.html` to test the WebRTC functionality:

1. Open `src/mediasoup/example-client.html` in a browser
2. Enter your server URL and JWT token
3. Create or join a room
4. Test audio/video and recording

### 6. Flutter Testing

1. **Unit Tests**: Test your Flutter service classes
2. **Integration Tests**: Test with real server
3. **Device Testing**: Test on real devices (not emulators)
4. **Network Testing**: Test with different network conditions
5. **Permission Testing**: Test camera/microphone permissions

## Best Practices

### 1. Room Management

- Create rooms with appropriate `maxParticipants` (2 for 1-to-1 calls)
- Clean up rooms when participants leave
- Use meaningful room IDs

### 2. Error Handling

- Always handle connection errors
- Implement retry logic for failed operations
- Show user-friendly error messages

### 3. Performance

- Monitor worker resource usage
- Clean up resources when calls end
- Use appropriate media quality settings

### 4. Security

- Validate all inputs
- Use HTTPS/WSS in production
- Implement proper authentication
- Secure recording file storage

### 5. Recording

- Monitor disk space for recordings
- Implement recording file cleanup
- Use appropriate codec settings for quality/size balance

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check server URL and port
   - Verify JWT token is valid
   - Check network connectivity

2. **Media Not Working**
   - Check camera/microphone permissions
   - Verify WebRTC is supported
   - Check browser console for errors

3. **Recording Failed**
   - Verify FFmpeg is installed
   - Check disk space
   - Verify recording directory permissions

4. **High CPU Usage**
   - Reduce number of workers
   - Lower video quality settings
   - Monitor resource usage

### Debug Mode

Enable debug logging:
```env
DEBUG=mediasoup:*
NODE_ENV=development
```

### Logs

Monitor these log types:
- Worker creation/destruction
- Room creation/closure
- Participant join/leave
- Recording start/stop
- Transport connection issues

This documentation provides a complete guide for integrating MediaSoup with Flutter applications. The backend handles all the complex WebRTC signaling and media processing, while Flutter apps can focus on the user interface and experience. 