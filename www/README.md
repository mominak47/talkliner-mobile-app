# Talkliner Web Client

A web-based LiveKit client that connects to the same infrastructure as the Talkliner Flutter app.

## Features

- 🎙️ **Push-to-Talk (PTT)** - Hold space bar or click the PTT button to transmit audio
- 🔐 **Authentication** - Login with Talkliner credentials
- 🎵 **Real-time Audio** - High-quality audio communication using LiveKit
- 👥 **Participant Management** - See who's in the room and their audio status
- 📱 **Responsive Design** - Works on desktop and mobile browsers
- 📊 **Live Logs** - Real-time connection and event logging

## Configuration

The web client is pre-configured to connect to:
- **LiveKit Server**: `wss://talkliner-nh2ljes1.livekit.cloud`
- **API Server**: `https://api.talkliner.com/`

These settings match the Flutter app configuration and should work out of the box.

## How to Use

### 1. Open the Web Client

**🚀 Recommended Method (Local SDK):**
```bash
cd www
python3 serve.py
# This will automatically open http://localhost:8000/index-local.html
```

**Alternative Methods:**
```bash
# Using Python 3
cd www
python -m http.server 8000
# Then open http://localhost:8000/index-local.html

# Using Node.js (if you have http-server installed)
cd www
npx http-server
# Then open http://localhost:8000/index-local.html
```

**📁 Available Files:**
- `index-local.html` - **Recommended** - Uses local LiveKit SDK (most reliable)
- `index-with-local-livekit.html` - Fallback with multiple CDN sources
- `index.html` - Original version with CDN loading

### 2. Login
1. Enter your Talkliner username and password
2. Click the "Login" button
3. Wait for authentication to complete

### 3. Connect to a Room
1. Enter a Chat/Room ID (this should match the room you want to join)
2. Click "Connect to Room"
3. Allow microphone permissions when prompted
4. Wait for the connection to establish

### 4. Use Push-to-Talk
- **Mouse**: Click and hold the PTT button
- **Keyboard**: Hold the Space bar
- The button turns red when transmitting
- Release to stop transmitting

### 5. Additional Controls
- **Toggle Mic**: Enable/disable your microphone (independent of PTT)
- **Toggle Camera**: Enable/disable your camera (if supported)
- **Disconnect**: Leave the current room

## Technical Details

### LiveKit Integration
The web client uses the official LiveKit JavaScript SDK and implements the same features as the Flutter app:

- Token-based authentication via the Talkliner API
- Real-time audio/video communication
- Data messaging for PTT signaling
- Participant management
- Audio track publishing/unpublishing

### PTT Implementation
The PTT functionality mirrors the Flutter app's behavior:

1. **PTT Start**: Publishes audio track and sends `ptt-speaking-start` data message
2. **PTT Active**: Audio is transmitted to all participants
3. **PTT End**: Mutes audio track and sends `ptt-speaking-end` data message

### Data Messages
The client sends and receives the same data message format as the Flutter app:

```javascript
// PTT Start
{
  type: "ptt-speaking-start",
  event: JSON.stringify({
    from: "participant_identity",
    timestamp: Date.now()
  })
}

// PTT End
{
  type: "ptt-speaking-end",
  event: JSON.stringify({
    from: "participant_identity", 
    timestamp: Date.now()
  })
}
```

### Browser Compatibility
- **Chrome/Chromium**: Full support
- **Firefox**: Full support
- **Safari**: Full support (iOS 14.3+)
- **Edge**: Full support

### Security Requirements
- HTTPS is required for microphone/camera access
- WebRTC requires secure contexts for media access
- Some browsers may block autoplay of audio elements

## Troubleshooting

### LiveKit SDK Loading Issues
1. **"LiveKit is not defined" Error**: 
   - Try the alternative version: `index-with-local-livekit.html`
   - Check browser console for network errors
   - Ensure you're serving the page via HTTP/HTTPS (not file://)
   - Try refreshing the page
   
2. **CDN Blocked**: If your network blocks CDN access:
   - Use `index-with-local-livekit.html` which tries multiple CDNs
   - Download LiveKit SDK locally and update the script src

### Connection Issues
1. **Login Failed**: Check username/password and network connectivity
2. **Token Error**: Ensure you're logged in and the API server is accessible
3. **LiveKit Connection Failed**: Check that the LiveKit server URL is correct and accessible

### Audio Issues
1. **No Microphone Access**: Check browser permissions and ensure HTTPS
2. **Can't Hear Others**: Check that audio elements are not blocked by browser autoplay policies
3. **PTT Not Working**: Ensure microphone permissions are granted and you're connected to a room

### Network Issues
1. **CORS Errors**: The API server should already be configured for CORS, but local testing may require a web server
2. **WebSocket Errors**: Check that WebSocket connections are not blocked by firewalls or proxies

### Browser-Specific Issues
1. **Chrome**: Usually works best, enable microphone permissions
2. **Firefox**: May need to manually allow autoplay in settings
3. **Safari**: Requires iOS 14.3+ for full WebRTC support
4. **Edge**: Should work similar to Chrome

## Development

### File Structure
```
www/
├── index-local.html                    # 🚀 Recommended - Uses local LiveKit SDK
├── index-with-local-livekit.html      # Fallback with multiple CDN sources  
├── index.html                         # Original version with CDN loading
├── livekit-client.umd.js              # Local LiveKit SDK file
├── serve.py                           # Python web server with auto-open
└── README.md                          # This documentation
```

### Key Components
- **TalklinerWebClient**: Main client class handling all functionality
- **Authentication**: Login and token management
- **LiveKit Integration**: Room connection and media handling  
- **PTT System**: Push-to-talk implementation
- **UI Management**: Status updates and participant display

### Extending the Client
The client is built as a single HTML file for simplicity, but can be easily extended:

1. **Add Video Support**: Implement video track publishing and display
2. **Chat Messages**: Add text messaging functionality
3. **File Sharing**: Implement file transfer via data channels
4. **Screen Sharing**: Add screen capture and sharing
5. **Recording**: Implement client-side recording capabilities

## API Endpoints Used

- `POST /api/domains/login` - User authentication
- `POST /api/livekit` - Get LiveKit token for room access

## Security Notes

- Tokens are stored in memory only (not persisted)
- All API communication uses HTTPS
- LiveKit uses secure WebSocket connections (WSS)
- No sensitive data is stored in browser storage
