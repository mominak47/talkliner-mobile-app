# Chat API Documentation

## Overview
This API provides comprehensive chat functionality including individual and group chats, messaging, participant management, and real-time features.

## Authentication
All chat routes require domain user authentication using Bearer token:
```
Authorization: Bearer <your_domain_user_token>
```

## Base URL
```
/chats
```

---

## 📋 Chat Management

### Get All User Chats
Get all chats for the authenticated user with pagination.

**Endpoint:** `GET /chats`

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Example Request:**
```bash
GET /chats?page=1&limit=10
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "chats": [
      {
        "_id": "chat_id",
        "chat_type": "individual",
        "participants": [
          {
            "user_id": {
              "_id": "user_id",
              "username": "john_doe",
              "display_name": "John Doe"
            },
            "role": "member",
            "last_seen": "2024-01-15T10:30:00.000Z"
          }
        ],
        "last_message": {
          "content": "Hello there!",
          "sender_id": {
            "username": "jane_doe",
            "display_name": "Jane Doe"
          },
          "timestamp": "2024-01-15T10:30:00.000Z"
        },
        "unread_count": 2,
        "createdAt": "2024-01-15T09:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 25,
      "page": 1,
      "limit": 10,
      "pages": 3
    }
  }
}
```

### Get Specific Chat
Get details of a specific chat by ID.

**Endpoint:** `GET /chats/:chat_id`

**Example Request:**
```bash
GET /chats/60f7b3b3b3b3b3b3b3b3b3b3
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "chat": {
      "_id": "60f7b3b3b3b3b3b3b3b3b3b3",
      "chat_type": "group",
      "name": "Project Team",
      "description": "Team discussion for the new project",
      "participants": [...],
      "messages": [...],
      "message_count": 45
    }
  }
}
```

### Search Chats
Search chats by name or message content.

**Endpoint:** `GET /chats/search`

**Query Parameters:**
- `query` (required): Search term
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Example Request:**
```bash
GET /chats/search?query=project&page=1&limit=5
Authorization: Bearer <token>
```

### Update Group Chat
Update group chat details (admin only).

**Endpoint:** `PUT /chats/:chat_id`

**Request Body:**
```json
{
  "name": "Updated Group Name",
  "description": "Updated description",
  "avatar": "https://example.com/avatar.jpg"
}
```

**Example Request:**
```bash
PUT /chats/60f7b3b3b3b3b3b3b3b3b3b3
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "New Project Team",
  "description": "Updated team discussion"
}
```

### Delete Chat
Delete/archive a chat.

**Endpoint:** `DELETE /chats/:chat_id`

**Example Request:**
```bash
DELETE /chats/60f7b3b3b3b3b3b3b3b3b3b3
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Chat deleted successfully"
}
```

---

## 💬 Chat Creation

### Create Individual Chat
Create a 1-on-1 chat with another user.

**Endpoint:** `POST /chats/individual`

**Request Body:**
```json
{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b4"
}
```

**Example Request:**
```bash
POST /chats/individual
Authorization: Bearer <token>
Content-Type: application/json

{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b4"
}
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "chat": {
      "_id": "new_chat_id",
      "chat_type": "individual",
      "participants": [
        {
          "user_id": {
            "_id": "current_user_id",
            "username": "current_user",
            "display_name": "Current User"
          },
          "role": "member"
        },
        {
          "user_id": {
            "_id": "60f7b3b3b3b3b3b3b3b3b3b4",
            "username": "other_user",
            "display_name": "Other User"
          },
          "role": "member"
        }
      ],
      "messages": [],
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

### Create Group Chat
Create a group chat with multiple participants.

**Endpoint:** `POST /chats/group`

**Request Body:**
```json
{
  "name": "Project Team",
  "description": "Team discussion for the new project",
  "participant_ids": [
    "60f7b3b3b3b3b3b3b3b3b3b4",
    "60f7b3b3b3b3b3b3b3b3b3b5",
    "60f7b3b3b3b3b3b3b3b3b3b6"
  ]
}
```

**Example Request:**
```bash
POST /chats/group
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Development Team",
  "description": "Daily standup and project updates",
  "participant_ids": ["user1_id", "user2_id", "user3_id"]
}
```

---

## 📨 Messaging

### Get Chat Messages
Get messages from a specific chat with pagination.

**Endpoint:** `GET /chats/:chat_id/messages`

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 50)

**Example Request:**
```bash
GET /chats/60f7b3b3b3b3b3b3b3b3b3b3/messages?page=1&limit=20
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "_id": "message_id",
        "sender_id": {
          "_id": "sender_id",
          "username": "john_doe",
          "display_name": "John Doe"
        },
        "content": "Hello everyone!",
        "message_type": "text",
        "timestamp": "2024-01-15T10:30:00.000Z",
        "edited": false
      }
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 20,
      "pages": 5
    }
  }
}
```

### Send Message
Send a message to a chat.

**Endpoint:** `POST /chats/:chat_id/messages`

**Request Body:**
```json
{
  "content": "Hello everyone!",
  "message_type": "text",
  "file_url": null,
  "file_name": null,
  "file_size": null,
  "reply_to": null
}
```

**Message Types:**
- `text` - Plain text message
- `image` - Image file
- `file` - Document/file attachment
- `audio` - Audio message
- `video` - Video file

**Example Request (Text Message):**
```bash
POST /chats/60f7b3b3b3b3b3b3b3b3b3b3/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Hello team! How's the project going?",
  "message_type": "text"
}
```

**Example Request (File Message):**
```bash
POST /chats/60f7b3b3b3b3b3b3b3b3b3b3/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Here's the project document",
  "message_type": "file",
  "file_url": "https://example.com/files/project.pdf",
  "file_name": "project_requirements.pdf",
  "file_size": 2048576
}
```

**Example Request (Reply Message):**
```bash
POST /chats/60f7b3b3b3b3b3b3b3b3b3b3/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "Thanks for sharing!",
  "message_type": "text",
  "reply_to": "original_message_id"
}
```

### Mark Chat as Read
Mark all messages in a chat as read.

**Endpoint:** `PATCH /chats/:chat_id/read`

**Example Request:**
```bash
PATCH /chats/60f7b3b3b3b3b3b3b3b3b3b3/read
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Chat marked as read"
}
```

---

## 👥 Participant Management

### Add Participant to Group Chat
Add a user to a group chat (admin only).

**Endpoint:** `POST /chats/:chat_id/participants`

**Request Body:**
```json
{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b7"
}
```

**Example Request:**
```bash
POST /chats/60f7b3b3b3b3b3b3b3b3b3b3/participants
Authorization: Bearer <token>
Content-Type: application/json

{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b7"
}
```

### Remove Participant from Group Chat
Remove a user from a group chat (admin or self-removal).

**Endpoint:** `DELETE /chats/:chat_id/participants`

**Request Body:**
```json
{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b7"
}
```

**Example Request:**
```bash
DELETE /chats/60f7b3b3b3b3b3b3b3b3b3b3/participants
Authorization: Bearer <token>
Content-Type: application/json

{
  "participant_id": "60f7b3b3b3b3b3b3b3b3b3b7"
}
```

---

## 🔄 Real-time Events

The API emits real-time events via Socket.IO:

### Events Emitted:
- `chat_created` - When a new chat is created
- `new_message` - When a message is sent
- `participant_added` - When a user joins a group chat
- `participant_removed` - When a user leaves a group chat
- `removed_from_chat` - When a user is removed from a chat
- `chat_updated` - When group chat details are updated
- `chat_deleted` - When a chat is archived

### Event Example:
```javascript
// Client-side Socket.IO listener
socket.on('new_message', (data) => {
  console.log('New message received:', data);
  // data structure:
  // {
  //   chat_id: "chat_id",
  //   message: { sender_id, content, timestamp, ... }
  // }
});
```

---

## 🚨 Error Responses

### Common Error Formats:

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Validation error message"
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "You are not logged in! Please log in to get access."
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Only admins can perform this action"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Chat not found or you do not have access"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Internal server error message"
}
```

---

## 📝 Usage Notes

### Permissions:
- **Individual Chats**: Both participants have equal access
- **Group Chats**: 
  - Admins can add/remove participants, update chat details, delete chat
  - Members can send messages, leave chat, view messages
  - Creator is automatically set as admin

### Pagination:
- All list endpoints support pagination
- Default page size is configurable per endpoint
- Results are sorted by most recent activity

### File Handling:
- File uploads should be handled separately
- Provide file URLs, names, and sizes in message requests
- Supported file types: images, documents, audio, video

### Search:
- Searches chat names and message content
- Case-insensitive matching
- Supports pagination

### Data Population:
- User information is automatically populated in responses
- Includes username, display_name, and avatar fields
- Sensitive information (passwords) is excluded

---

## 🔧 Integration Example

```javascript
// Example integration in a React component
const ChatAPI = {
  baseURL: '/chats',
  headers: {
    'Authorization': `Bearer ${userToken}`,
    'Content-Type': 'application/json'
  },

  // Get user chats
  async getChats(page = 1, limit = 20) {
    const response = await fetch(`${this.baseURL}?page=${page}&limit=${limit}`, {
      headers: this.headers
    });
    return response.json();
  },

  // Send message
  async sendMessage(chatId, content, messageType = 'text') {
    const response = await fetch(`${this.baseURL}/${chatId}/messages`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ content, message_type: messageType })
    });
    return response.json();
  },

  // Create individual chat
  async createIndividualChat(participantId) {
    const response = await fetch(`${this.baseURL}/individual`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ participant_id: participantId })
    });
    return response.json();
  }
};
```

This API provides a complete chat solution with real-time capabilities, file sharing, group management, and comprehensive search functionality. 