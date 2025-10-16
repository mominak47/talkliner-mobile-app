# Talkliner - Mediasoup Video Calling

A complete video calling solution using Mediasoup with both Flutter mobile app and web browser support.

## Features

- 🎥 Real-time video/audio communication
- 📱 Flutter mobile app
- 🌐 Web browser client
- 🔄 Room-based video calls
- 🎤 Mute/unmute controls
- 📹 Video enable/disable
- 👥 Multi-participant support
- 📡 Socket.IO signaling

## Project Structure

```
talkliner-main/
├── lib/
│   └── mediasoup.dart          # Flutter video calling screen
├── mediasoup-server/           # Node.js mediasoup server
│   ├── server.js               # Main server file
│   ├── package.json            # Server dependencies
│   ├── public/
│   │   └── index.html          # Web client
│   └── README.md               # Server documentation
└── README.md                   # This file
```

## Quick Start

### 1. Start the Mediasoup Server

```bash
# Navigate to server directory
cd mediasoup-server

# Install dependencies
npm install

# Start the server
npm start
```

The server will start on `http://localhost:3000`

### 2. Test with Web Client

1. Open your browser and go to `http://localhost:3000`
2. Enter a room ID (e.g., "test-room")
3. Enter a username (e.g., "Web User")
4. Click "Join Room"
5. Allow camera and microphone permissions

### 3. Test with Flutter App

1. Run the Flutter app
2. Navigate to the Mediasoup screen
3. Enter the same room ID as the web client
4. Enter a different username (e.g., "Flutter User")
5. Click "Join Room"

## Server Configuration

### Environment Variables

Create a `.env` file in the `mediasoup-server` directory:

```env
PORT=3000
MEDIASOUP_LISTEN_IP=0.0.0.0
MEDIASOUP_ANNOUNCED_IP=127.0.0.1
```

### Public IP Configuration

If you're running this on a server with a public IP, update the `announcedIp` in `server.js`:

```javascript
webRtcTransport: {
  listenIps: [
    {
      ip: '0.0.0.0',
      announcedIp: 'YOUR_PUBLIC_IP_HERE' // Change this
    }
  ],
  // ... other config
}
```

## API Endpoints

### Socket.IO Events

#### Client to Server
- `join-room`: Join a video call room
- `create-transport`: Create WebRTC transport
- `connect-transport`: Connect transport with DTLS parameters
- `produce`: Start producing media (audio/video)
- `consume`: Start consuming media from other peers
- `resume-consumer`: Resume a paused consumer

#### Server to Client
- `user-joined`: Notify when a new user joins
- `user-left`: Notify when a user leaves
- `new-producer`: Notify when a new media producer is available

## Flutter Integration

The Flutter app uses the following packages:
- `flutter_webrtc`: WebRTC functionality
- `socket_io_client`: Socket.IO client
- `mediasoup_client_flutter`: Mediasoup client (for future full integration)

### Current Implementation

The current Flutter implementation provides:
- Socket.IO connection to the server
- Local camera/microphone access
- Basic room joining functionality
- Mute/unmute and video toggle controls

### Future Enhancements

To complete the mediasoup integration, you would need to:
1. Implement the full mediasoup client API
2. Add transport creation and management
3. Implement media production and consumption
4. Handle remote video streams

## Testing

### Local Testing

1. **Single Browser Test**: Open multiple tabs with the web client
2. **Cross-Platform Test**: Use web client + Flutter app
3. **Network Test**: Test with different network conditions

### Browser Compatibility

The web client works with:
- Chrome (recommended)
- Firefox
- Safari
- Edge

### Mobile Testing

For Flutter app testing:
- Use real devices (not emulators)
- Ensure camera/microphone permissions
- Test on both iOS and Android

## Troubleshooting

### Common Issues

1. **Camera/Microphone Not Working**
   - Ensure you're using HTTPS or localhost
   - Check browser permissions
   - Verify device permissions on mobile

2. **Connection Issues**
   - Check server is running on correct port
   - Verify `announcedIp` is set correctly
   - Check firewall settings

3. **Video Not Displaying**
   - Check WebRTC support in browser
   - Verify camera permissions
   - Check console for errors

4. **Server Won't Start**
   - Check Node.js version (v16+ required)
   - Verify all dependencies are installed
   - Check port availability

### Debug Mode

Enable debug logging in the server:

```javascript
// In server.js
const config = {
  mediasoup: {
    worker: {
      logLevel: 'debug', // Change from 'warn' to 'debug'
      // ...
    }
  }
};
```

### Logs

Monitor these log types:
- Socket connection events
- Room creation/joining
- Transport creation
- Media production/consumption
- Error messages

## Security Considerations

⚠️ **Important**: This is a development setup. For production:

1. **Authentication**: Implement proper user authentication
2. **HTTPS**: Use HTTPS/WSS for all connections
3. **Rate Limiting**: Add rate limiting to prevent abuse
4. **Input Validation**: Validate all user inputs
5. **Recording Security**: Secure recording file storage
6. **Network Security**: Configure firewalls appropriately

## Performance Optimization

1. **Worker Management**: Adjust number of mediasoup workers based on load
2. **Media Quality**: Configure appropriate bitrates and codecs
3. **Resource Cleanup**: Ensure proper cleanup of resources
4. **Monitoring**: Monitor CPU and memory usage

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the server logs
3. Check browser console for errors
4. Create an issue with detailed information

---

**Note**: This implementation provides a foundation for video calling. The Flutter app currently shows local video and connects to the server, but full mediasoup integration requires additional development work to handle remote video streams and complete the WebRTC signaling.
