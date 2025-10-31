Relexwise - Tanmay Lautawar

Table of Contents
- What is Relexwise?
- Features
- Tech Stack
- Project Structure
- Prerequisites
- Quick Start (10 minutes)
- Backend Setup (Detailed)
- Mobile App Setup (Detailed)
- Push Notifications (FCM) Setup
- Environment Variables (Cheat Sheet)
- Useful Scripts
- Troubleshooting

What is Relexwise?
Relexwise is a video learning app. Users can:
- Browse a feed of videos
- Open and watch videos
- Favorite videos (saved locally on device)
- Receive push notifications
- 
Features
- Backend API with NestJS + TypeORM + PostgreSQL
- Production-ready database configuration for AWS RDS (with SSL)
- Mobile app built in Flutter (Android, iOS, Web, Desktop capable)
- Local favorites persistence (SharedPreferences)
- Foreground and background notifications using Firebase Cloud Messaging + flutter_local_notifications
- Clean routing and a bottom navigation shell (Home, Favorites, Cached, Profile)

Tech Stack
- Backend: Node.js, NestJS, TypeORM, PostgreSQL
- Mobile: Flutter (Dart)
- Push: Firebase Cloud Messaging (FCM)
- Build/Dev: npm, Flutter SDK, Android Studio/Xcode (for device builds)

Project Structure
```
./
  backend/                # NestJS API
    src/                  # Source code
    dist/                 # Build output (generated)
    env.example           # Sample env file for backend
    package.json          # Node scripts
  mobile/                 # Flutter app
    lib/                  # Dart source code
    android/ ios/         # Platform folders
    pubspec.yaml          # Flutter dependencies
  ARCHITECTURE.md         # High-level architecture notes
  README.md               # You are here
```

Prerequisites
Install these once:
- Node.js 18+ and npm
- PostgreSQL (local) OR an AWS RDS PostgreSQL instance
- Flutter SDK 3.x and Android Studio (or Xcode on macOS for iOS)
- A GitHub account (optional, for version control)

Quick Start (10 minutes)
1) Clone and open the project
```
cd C:\Users\tanma\Desktop\tannmay-relexwise
```

2) Backend: copy env and run
```
cd backend
copy env.example .env
# Edit .env and set DB_*, JWT_SECRET, etc.
npm install
npm run start:dev
```
Expected: “Nest application running on http://localhost:3000” and TypeORM connects to your DB.

3) Mobile: run the Flutter app
```
cd ..\mobile
flutter pub get
flutter run
```
Expected: App builds and opens with bottom tabs. If Firebase files are missing, notifications still work without them but FCM won’t.

Backend Setup (Detailed)
1) Configure Database
- Local: use Postgres installed on your machine (DB_HOST=localhost)
- Production: AWS RDS (get endpoint, username, password). Create a database in pgAdmin named the same as DB_NAME.

2) Set environment variables
In `backend/.env` (based on `env.example`):
```
DB_HOST=your-db-host           # localhost for local, RDS endpoint for AWS
DB_PORT=5432
DB_USERNAME=postgres           # or RDS user
DB_PASSWORD=yourpassword
DB_NAME=streamsync             # create this db first (pgAdmin)

NODE_ENV=development           # dev enables auto schema sync
PORT=3000
JWT_SECRET=change-me
```
Notes:
- SSL is enabled automatically for non-local hosts (RDS). No extra cert steps needed due to `rejectUnauthorized: false` config.
- For production: set `NODE_ENV=production` and manage schema via migrations.

3) Run the backend
```
cd backend
npm install
npm run start:dev
```

Mobile App Setup (Detailed)
1) Install Flutter dependencies
```
cd mobile
flutter pub get
```

2) Optional: Configure Firebase for push notifications
- Android: place `google-services.json` in `mobile/android/app/`
- iOS: place `GoogleService-Info.plist` in `mobile/ios/Runner/`

3) Run the app
```
flutter run
```
The app has a bottom navigation with:
- Home: feed and playback
- Favorites: your locally saved favorites
- Cached: placeholder screen (ready for download/cache feature)
- Profile: user info and test push trigger

Push Notifications (FCM) Setup
Already wired for foreground and background notifications.
Steps:
1) Add platform files as above (google-services.json / GoogleService-Info.plist)
2) Ensure you request notification permission on first launch (Android 13+ is handled)
3) Send a test message from your backend (Profile → Test Push), or via Firebase Console
Behavior:
- Foreground: shows a local notification mirroring your title/body
- Background: handled via background isolate and shows the same title/body

Environment Variables (Cheat Sheet)
Backend (`backend/.env`):
- DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_NAME
- NODE_ENV, PORT
- JWT_SECRET, JWT_EXPIRATION (optional)
- Firebase admin credentials (optional) if sending notifications from server

Useful Scripts
Backend (`backend/package.json`):
- `npm run start:dev` – run API with reload
- `npm run build` / `npm run start:prod` – production build and run
- `npm run migration:generate` / `npm run migration:run` – TypeORM migrations (when `NODE_ENV=production`)

Flutter (from `mobile/`):
- `flutter pub get` – install Dart packages
- `flutter run` – run app on device/emulator
- `flutter build apk` – build Android APK

Troubleshooting
Database “does not exist”
- Create the database in pgAdmin, or set `DB_NAME=postgres` temporarily to verify connectivity.

Cannot connect to RDS
- Open security group inbound on TCP 5432 for your public IP
- Ensure the DB is in “Available” state
- Keep `DB_SSL=true` or rely on automatic SSL for non-local host

Firebase notifications show default text
- Ensure you send either `notification` (title/body) or data fields `title`/`body`. The app falls back to data values if notification is missing.

Android build error: desugaring
- We already enabled core library desugaring. If errors persist, run `flutter clean` then `flutter run`.

iOS specific setup
- Use Xcode 14+, open `ios/Runner.xcworkspace`, set a valid bundle id and signing team, then run.

Contributing
1) Create a feature branch from `main`
2) Commit changes with clear messages
3) Open a Pull Request

License
MIT


