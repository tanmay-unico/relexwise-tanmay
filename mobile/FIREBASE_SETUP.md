# Firebase Setup for Mobile App

## 🚨 App Crash Fix

Your app crashed because Firebase configuration is missing. Here's how to fix it:

---

## ✅ Quick Fix: Make Firebase Optional

**Already done!** The app now runs without Firebase.

**What changed:**
- Firebase initialization is now optional
- App won't crash if Firebase is missing
- Firebase features won't work until configured

---

## 🔧 Complete Firebase Setup (For Push Notifications)

To enable Firebase features (especially push notifications), follow these steps:

### Step 1: Get Firebase Configuration File

1. Go to Firebase Console: https://console.firebase.google.com
2. Select project: **streamsync-lite-fe05c**
3. Click ⚙️ (Settings) → **Project Settings**
4. Scroll down to **Your apps** section
5. If Android app doesn't exist:
   - Click **Add app** → Android
   - Package name: `com.example.streamsync` (or your package name)
   - Click **Register app**
6. Download **google-services.json**

### Step 2: Place File in Correct Location

1. Copy the downloaded `google-services.json` file
2. Navigate to: `mobile/android/app/`
3. Paste `google-services.json` here

**File path should be:**
```
mobile/
  android/
    app/
      google-services.json  ← HERE
```

### Step 3: Configure Android Build

1. Open `mobile/android/build.gradle`
2. Add this to the `dependencies` section:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

3. Open `mobile/android/app/build.gradle`
4. Add at the very bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Clean and Rebuild

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

---

## 🎯 What Firebase Features Need This

- ✅ **Push Notifications** - Requires Firebase
- ⚠️ **Test Push** - Won't work without Firebase
- ✅ **Other features** - Work without Firebase

---

## 🆘 Check if File is in Right Place

**Verify:**
1. File exists: `mobile/android/app/google-services.json`
2. File name is exactly: `google-services.json` (not `google-services (1).json`)
3. File contains valid JSON

**Test:**
```bash
# Navigate to mobile directory
cd mobile

# Check if file exists
dir android\app\google-services.json
```

---

## 📝 Package Name Check

Your app's package name is in: `mobile/android/app/build.gradle`

Look for:
```gradle
applicationId "com.example.streamsync"
```

**Make sure Firebase project uses the SAME package name!**

If different:
1. Either change package name in build.gradle
2. Or create new Firebase app with correct package name

---

## ✅ Quick Test

After adding `google-services.json`:

1. Restart app: Press `R` in terminal (hot restart)
2. Or rebuild: `flutter run`
3. Check terminal - should NOT see Firebase error
4. Push notifications will now work!

---

## 🚀 For iOS (If Needed Later)

1. In Firebase Console → Project Settings
2. Add iOS app (if not added)
3. Bundle ID: `com.example.streamsync`
4. Download `GoogleService-Info.plist`
5. Place in: `mobile/ios/Runner/GoogleService-Info.plist`
6. Open Xcode and add file to Runner target

---

## 💡 Current Status

- ✅ App runs without Firebase (won't crash)
- ❌ Push notifications won't work (until Firebase configured)
- ✅ All other features work

**To enable push notifications:** Follow steps above to add Firebase config!

---

**Your app should now run without crashing!** 🎉

To enable Firebase later: Just add `google-services.json` and rebuild.

