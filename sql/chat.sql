-- Chats Table
CREATE TABLE chats (
    id TEXT PRIMARY KEY,
    domain_id TEXT NOT NULL,
    chat_type TEXT NOT NULL,
    name TEXT,
    description TEXT,
    avatar TEXT,
    unread_count INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_by TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    -- Flattened Settings
    mute_notifications INTEGER DEFAULT 0,
    auto_delete_messages INTEGER DEFAULT 0,
    -- Flattened Last Message (Snapshot)
    last_message_content TEXT,
    last_message_sender_id TEXT,
    last_message_timestamp TEXT
);

-- Users Table (to store participant details)
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    display_name TEXT NOT NULL,
    profile_picture TEXT
);

-- Participants Table
CREATE TABLE participants (
    id TEXT PRIMARY KEY, -- The participant ID from the API
    chat_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role TEXT NOT NULL,
    joined_at TEXT NOT NULL,
    last_seen TEXT NOT NULL,
    FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Messages Table
CREATE TABLE messages (
    id TEXT PRIMARY KEY,
    chat_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT NOT NULL,
    file_url TEXT,
    file_name TEXT,
    file_size INTEGER,
    timestamp TEXT NOT NULL,
    edited INTEGER DEFAULT 0,
    edited_at TEXT,
    reply_to TEXT,
    is_me INTEGER DEFAULT 0,
    FOREIGN KEY (chat_id) REFERENCES chats (id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE SET NULL
);
