# StreamSync Lite - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         MOBILE APP (Flutter)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Splash  │─▶│  Login   │─▶│   Home   │─▶│  Video   │       │
│  │  Screen  │  │          │  │   Feed   │  │ Player   │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│       │             │             │              │              │
│       ▼             ▼             ▼              ▼              │
│  ┌──────────┐  ┌──────────────────────────────────┐           │
│  │  Notif.  │  │         Profile / Test Push      │           │
│  │   List   │  └──────────────────────────────────┘           │
│  └──────────┘                  │                              │
│                                ▼                              │
│  ┌────────────────────────────────────────────────────────┐   │
│  │              Local Database (Drift/SQLite)             │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐         │   │
│  │  │ Videos │ │Progress│ │Favs    │ │Notifs  │         │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘         │   │
│  └────────────────────────────────────────────────────────┘   │
│                                │                              │
│                                ▼                              │
│  ┌────────────────────────────────────────────────────────┐   │
│  │                 BLoC State Management                  │   │
│  └────────────────────────────────────────────────────────┘   │
│                                │                              │
│                                ▼                              │
│  ┌────────────────────────────────────────────────────────┐   │
│  │              Repository Pattern (Data Layer)           │   │
│  │         ┌─────────────┐         ┌─────────────┐       │   │
│  │         │   Local     │         │   Remote    │       │   │
│  │         │   Source    │         │   API       │       │   │
│  │         └─────────────┘         └─────────────┘       │   │
│  └────────────────────────────────────────────────────────┘   │
│                                │                              │
│                                ▼                              │
│  ┌────────────────────────────────────────────────────────┐   │
│  │          Firebase Cloud Messaging (FCM)               │   │
│  │                    Push Notifications                  │   │
│  └────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │   HTTPS/REST API      │
                    └───────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND SERVER (NestJS)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Nginx Reverse Proxy                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              NestJS Application (Node.js)                │  │
│  │                                                           │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │  │
│  │  │   Auth   │ │  Users   │ │  Videos  │ │ Notifs   │   │  │
│  │  │  Module  │ │  Module  │ │  Module  │ │  Module  │   │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │  │
│  │      │            │             │             │         │  │
│  │      ▼            ▼             ▼             ▼         │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │           Shared Services & Config              │   │  │
│  │  │  • JWT Auth Guard                               │   │  │
│  │  │  • Validation Pipe                             │   │  │
│  │  │  • Firebase Admin                              │   │  │
│  │  │  • Database Connection                         │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  │                                                           │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │         Notification Worker (Cron)              │   │  │
│  │  │  • Polls notification_jobs every 10s            │   │  │
│  │  │  • Sends via Firebase Admin SDK                 │   │  │
│  │  │  • Retry logic with exponential backoff         │   │  │
│  │  │  • DLQ for failed jobs                          │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │     External APIs                                        │  │
│  │  ┌──────────────┐         ┌──────────────┐             │  │
│  │  │   YouTube    │         │   Firebase   │             │  │
│  │  │  Data API    │         │  FCM Admin   │             │  │
│  │  └──────────────┘         └──────────────┘             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  AWS RDS PostgreSQL DATABASE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  users   │  │  videos  │  │ progress │  │favorites │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │fcm_tokens│  │notifications│notify_jobs│pending_acts │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. User Registration/Login Flow

```
User → Mobile App
  ↓
Enter credentials
  ↓
POST /auth/register or /auth/login
  ↓
Backend validates and hashes password
  ↓
Generate JWT token
  ↓
Return token to client
  ↓
Store token locally
  ↓
Register FCM token
  ↓
POST /users/:id/fcmToken
  ↓
Backend stores FCM token
```

### 2. Video Feed Flow

```
User opens app
  ↓
Mobile app checks local DB
  ↓
If stale or empty:
  → GET /videos/latest
    ↓
  Backend checks cache
  ↓
  If expired:
    → Fetch from YouTube API
    ↓
  Store in cache
  ↓
  Return to client
  ↓
Mobile app stores in local DB
  ↓
Display video cards
```

### 3. Video Playback Flow

```
User taps video
  ↓
Initialize YouTube player with videoId
  ↓
Check local progress
  ↓
Resume from saved position
  ↓
Play video
  ↓
On position update:
  → Save to local DB (synced=false)
  ↓
Periodically:
  → POST /videos/progress
  ↓
Backend saves to DB
  ↓
Mark as synced
```

### 4. Push Notification Flow

```
User initiates Test Push
  ↓
Fill title/body in Profile
  ↓
POST /notifications/send-test
  ↓
Backend:
  → Rate limit check
  → Idempotency check
  → Create notification record
  → Create notification_job
  ↓
Worker picks up job
  ↓
Fetches user's FCM tokens
  ↓
Firebase Admin SDK sends push
  ↓
Update job status (sent/failed)
  ↓
Mobile app receives notification
  ↓
Display in app
  ↓
Store in local DB
```

### 5. Notification Swipe Delete Flow

```
User swipes notification
  ↓
Optimistic delete (local UI)
  ↓
Mark as deleted in local DB
  ↓
Queue for sync (pending_actions)
  ↓
If online:
  → DELETE /notifications/:id
  ↓
Backend marks as deleted
  ↓
If offline:
  → Store in pending queue
  ↓
Sync on reconnect
```

## Component Responsibilities

### Backend Modules

**Auth Module**:
- User registration and login
- JWT token generation/validation
- Password hashing and verification

**Users Module**:
- FCM token management
- User profile operations

**Videos Module**:
- YouTube API integration
- Video metadata caching
- Progress tracking
- Favorites management

**Notifications Module**:
- Notification CRUD operations
- Rate limiting
- Idempotency handling
- Test push endpoint

**Notification Worker**:
- Job queue processing
- FCM message sending
- Retry logic
- Error handling

### Frontend Features

**Auth Feature**:
- Splash, login, register screens
- Token management
- Auto-login

**Home Feature**:
- Video feed display
- Pull-to-refresh
- Favorite toggling
- Share functionality

**Video Feature**:
- YouTube player integration
- Progress tracking
- Playback controls

**Notifications Feature**:
- Notification list
- Badge counts
- Swipe deletion
- Mark as read

**Profile Feature**:
- User info display
- Test Push UI
- Settings

## Database Schema

### Tables

**users** (User accounts)
- id, email, name, passwordHash, role, createdAt

**videos** (YouTube video metadata)
- videoId (PK), title, description, thumbnailUrl, channelId, 
  channelName, publishedAt, durationSeconds, cacheExpiry

**progress** (Watch progress)
- id, userId, videoId, positionSeconds, completedPercent, 
  synced, updatedAt
- Unique(userId, videoId)

**favorites** (User favorites)
- id, userId, videoId, synced, createdAt
- Unique(userId, videoId)

**fcm_tokens** (Device tokens)
- id, userId, token, platform, createdAt

**notifications** (Push notifications)
- id (PK), userId, title, body, metadata, isRead, isDeleted, 
  sent, receivedAt, createdAt

**notification_jobs** (Queue for sending)
- id, notificationId, userId, fcmTokens, status, retries, 
  lastError, messageId, createdAt, processingAt

**pending_actions** (Offline sync queue)
- id, userId, actionType, payload, synced, createdAt

## Technology Stack

### Backend
- **Framework**: NestJS 10+
- **Language**: TypeScript 5+
- **ORM**: TypeORM 0.3+
- **Database**: PostgreSQL 15
- **Auth**: JWT, bcrypt
- **Queue**: DB-backed queue
- **Push**: Firebase Admin SDK
- **Video**: YouTube Data API v3
- **Deploy**: AWS EC2 + PM2 + Nginx

### Frontend
- **Framework**: Flutter 3+
- **Language**: Dart 3+
- **State**: BLoC 8+
- **DB**: Drift 2+ (SQLite)
- **Push**: Firebase Cloud Messaging
- **Video**: youtube_player_flutter 9+
- **Network**: Dio 5+, Retrofit 4+
- **UI**: Material Design 3

### Infrastructure
- **Database**: AWS RDS (PostgreSQL)
- **Compute**: AWS EC2 (t2.micro)
- **Reverse Proxy**: Nginx
- **Process Manager**: PM2
- **Containerization**: Docker
- **Monitoring**: CloudWatch (optional)

## Security Architecture

### Authentication
- JWT tokens with expiration
- Secure password hashing (bcrypt, 10 rounds)
- Token validation on protected routes
- Auto-refresh mechanism (can be added)

### Authorization
- Role-based access (structure ready)
- User owns their data
- Guards on all protected endpoints

### Data Protection
- No secrets in client code
- Environment variables for config
- HTTPS/TLS for transport
- Input validation and sanitization
- SQL injection protection (ORM)

### Rate Limiting
- 5 requests/minute per user (test push)
- In-memory tracking (production: Redis)
- 429 responses on limit exceeded

## Scalability Considerations

### Current (Free Tier)
- Single EC2 instance
- Single RDS database
- In-memory rate limiting
- Local notification queue

### Production Scaling
- Load balancer + multiple instances
- Redis for rate limiting and caching
- RDS read replicas
- Queue service (SQS/Redis)
- CDN for static assets
- Auto-scaling groups

## Monitoring & Logging

### Logs
- PM2 log rotation
- CloudWatch integration
- Error logging
- Request logging

### Health Checks
- `/health` endpoint
- Database connectivity
- Service availability

### Metrics
- Request counts
- Error rates
- Job queue length
- FCM success/failure rates

## Deployment Architecture

### Development
- Docker Compose
- Local PostgreSQL
- Hot reload

### Production
- AWS EC2 with PM2
- AWS RDS PostgreSQL
- Nginx reverse proxy
- SSL/TLS termination
- Docker support (optional)

This architecture supports offline-first operation, push notifications, and scalable growth while maintaining security and performance.

