# 🏘️ Colony - Location-Based Social Community App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.11.4-02569B?style=for-the-badge&logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-2.8.0-3FCF8E?style=for-the-badge&logo=supabase)
![Dart](https://img.shields.io/badge/Dart-3.11.4-0175C2?style=for-the-badge&logo=dart)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=for-the-badge&logo=postgresql)

**A real-time location-based social networking app for neighborhoods**

[Features](#-features) • [Architecture](#-architecture) • [Setup](#-setup) • [Testing](#-testing)

</div>

---

## 📖 Table of Contents

- [Overview](#overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Setup & Installation](#-setup--installation)
  - [1. Clone Repository](#1-clone-repository)
  - [2. Flutter Setup](#2-flutter-setup)
  - [3. Supabase Setup](#3-supabase-setup)
  - [4. Database Schema Setup](#4-database-schema-setup)
  - [5. Environment Configuration](#5-environment-configuration)
  - [6. Run the App](#6-run-the-app)
- [Implementation Status](#-implementation-status)
- [Database Schema](#-database-schema)
- [API & Backend](#-api--backend)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## Overview

**Colony** is a location-based social community app that helps users discover and connect with neighbors, join local groups, discover nearby events, and build stronger communities. The app features real-time location tracking, social interactions, and gamification elements.

### Key Highlights

- 🎯 **Real-time Location Tracking** - Continuous GPS updates every 50 meters
- 👥 **Community Discovery** - Find nearby users, groups, and events
- 💬 **Social Features** - Waves (friend requests), chat, stories
- 🎮 **Gamification** - Karma points, achievements, daily streaks
- 🔐 **Secure Auth** - Phone OTP, email verification, device fingerprinting
- 📍 **Privacy First** - Location never shared publicly, only approximate distance

---

## ✨ Features

### ✅ Implemented (Phases 1-11)

#### 🔐 Authentication & Onboarding
- Email/Password signup with validation
- Phone OTP verification (optional)
- Email verification with auto-check
- Device fingerprinting for fraud prevention
- 5-step beautiful onboarding flow:
  1. Welcome screen with Colony branding
  2. Profile setup (avatar, name, username, bio, DOB, gender)
  3. Interests selection (20+ categories)
  4. Location permission with animated radar
  5. Completion with profile preview

#### 📍 Location Services
- Real-time GPS tracking (50m distance filter)
- Reverse geocoding for location names
- Battery-optimized tracking (app lifecycle aware)
- Online/offline status auto-management
- Ghost mode support (premium feature)

#### 📱 Core App Structure
- Clean architecture (Feature-first)
- State management with Provider
- Supabase backend integration
- Real-time location updates to database
- Beautiful green theme UI with custom animations

### 🚧 In Development

- Home screen with nearby users discovery
- Groups/Hives creation and management
- Events creation and RSVP system
- Real-time chat and messaging
- Stories creation and viewing
- Waves (connection requests) system
- User profile and visual journal
- Push notifications
- Gamification (karma, achievements, streaks)
- Premium subscription features

---

## 🏗️ Architecture

```
lib/
├── core/                      # Core utilities and services
│   ├── constants/
│   │   └── supabase_constants.dart    # Supabase configuration
│   ├── services/
│   │   ├── supabase_service.dart      # Supabase client wrapper
│   │   └── location_service.dart      # GPS tracking service
│   ├── widgets/
│   │   ├── location_header_widget.dart    # Location display widget
│   │   ├── location_radar_widget.dart     # Radar animation widget
│   │   └── location_loading_screen.dart   # Location loading UI
│   ├── theme/
│   └── utils/
│
├── features/                  # Feature-based modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart        # Auth API calls
│   │   │   └── auth_state_notifier.dart    # Auth state management
│   │   ├── domain/
│   │   │   └── auth_validators.dart       # Input validation
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── phone_verification_screen.dart
│   │       │   ├── email_verification_screen.dart
│   │       │   ├── onboarding_flow_screen.dart
│   │       │   └── onboarding_steps/
│   │       │       ├── step1_welcome.dart
│   │       │       ├── step2_profile_setup.dart
│   │       │       ├── step3_interests.dart
│   │       │       ├── step4_location_permission.dart
│   │       │       └── step5_ready.dart
│   │       ├── widgets/
│   │       │   └── otp_input_field.dart
│   │       └── controllers/
│   │           └── onboarding_controller.dart
│   ├── home/
│   │   └── domain/
│   │       └── models/
│   │           └── nearby_user.dart
│   ├── chat/
│   ├── groups/
│   ├── profile/
│   ├── events/
│   ├── stories/
│   └── notifications/
│
├── screens/                   # App screens
│   ├── main_navigation_screen.dart   # Bottom navigation
│   ├── home_screen.dart
│   ├── chat_list_screen.dart
│   ├── groups_screen.dart
│   └── profile_screen.dart
│
├── login_screen.dart
├── signup_screen.dart
└── main.dart                  # App entry point
```

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** >= 3.11.4 ([Install Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK** >= 3.11.4 (included with Flutter)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **VS Code** or any preferred IDE
- **Git** for version control
- **Supabase Account** ([Sign up free](https://supabase.com))

---

## 📦 Project Structure

```
colony-app/
├── Project/
│   └── Frontend/              # Flutter mobile app
│       ├── android/
│       ├── ios/
│       ├── lib/
│       ├── test/
│       └── pubspec.yaml
│
├── supabase/                  # Supabase configuration
│   ├── config.toml
│   ├── migrations/
│   │   └── 20260404153000_add_onboarding_completed.sql
│   └── seed.sql
│
├── Project/supabase/sql/      # Database schema files
│   ├── 00_master_complete.sql
│   ├── 01_core_tables.sql
│   ├── 02_social_tables.sql
│   ├── 03_extended_tables.sql
│   ├── 04_rls_policies.sql
│   ├── 05_functions_triggers.sql
│   ├── 06_realtime.sql
│   ├── 07_storage_buckets.sql
│   ├── 08_fix_username_check.sql
│   └── 09_add_onboarding_completed.sql
│
├── QUICK_DATABASE_SETUP.sql   # One-file complete setup
├── DATABASE_SETUP_INSTRUCTIONS.md
└── README.md
```

---

## 🚀 Setup & Installation

### 1. Clone Repository

```bash
# Clone the repository
git clone https://github.com/devamsshinde/colony-app.git

# Navigate to project directory
cd colony-app

# Check current status
git status
```

### 2. Flutter Setup

```bash
# Navigate to Flutter project
cd Project/Frontend

# Install dependencies
flutter pub get

# Check Flutter version
flutter --version  # Should be >= 3.11.4

# Verify Flutter setup
flutter doctor
```

### 3. Supabase Setup

#### 3.1 Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click **"New Project"**
3. Enter project details:
   - **Name:** `Colony`
   - **Database Password:** Choose a strong password (save it!)
   - **Region:** Select closest to your users
4. Click **"Create new project"** and wait ~2 minutes

#### 3.2 Get API Credentials

1. In Supabase Dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (e.g., `https://pfcqskmitzeclipipvak.supabase.co`)
   - **anon public** key (for client-side)
   - **service_role** key (keep secret!)

#### 3.3 Update Flutter Configuration

Edit `Project/Frontend/lib/core/constants/supabase_constants.dart`:

```dart
class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  static const String supabaseServiceRoleKey = 'YOUR_SERVICE_ROLE_KEY';
}
```

### 4. Database Schema Setup

**⚠️ CRITICAL: This MUST be done before running the app!**

#### Option A: Quick Setup (Recommended)

1. **Open SQL File:**
   - Open `QUICK_DATABASE_SETUP.sql` in the project root

2. **Copy SQL Content:**
   ```bash
   # On Windows
   notepad QUICK_DATABASE_SETUP.sql
   # Copy all content (Ctrl+A, Ctrl+C)

   # On Mac/Linux
   cat QUICK_DATABASE_SETUP.sql
   # Copy all content
   ```

3. **Open Supabase SQL Editor:**
   - Go to: https://supabase.com/dashboard/project/YOUR_PROJECT_REF/sql
   - Click **"New Query"**

4. **Paste & Execute:**
   - Paste the SQL content (Ctrl+V)
   - Click **"Run"** button
   - Wait for success message: `✅ COLONY DATABASE SETUP COMPLETE!`

5. **Reload Schema Cache:**
   - Go to: Settings → API
   - Scroll to **"Schema Cache"**
   - Click **"Reload Schema Cache"**
   - Wait 10-30 seconds

#### Option B: Step-by-Step Setup

Run each file in order from `Project/supabase/sql/`:
1. `01_core_tables.sql` - User profiles, device logs
2. `02_social_tables.sql` - Chat, messages, groups, events
3. `03_extended_tables.sql` - Stories, waves, achievements
4. `04_rls_policies.sql` - Row Level Security
5. `05_functions_triggers.sql` - Database functions
6. `06_realtime.sql` - Realtime subscriptions
7. `07_storage_buckets.sql` - File storage
8. `08_fix_username_check.sql` - Username validation
9. `09_add_onboarding_completed.sql` - Onboarding flag

### 5. Environment Configuration

No `.env` file needed for Flutter app! All config is in `supabase_constants.dart`.

**Note:** The backend `.env` file is not used (we removed Node.js backend as Supabase handles everything).

### 6. Run the App

```bash
# Navigate to Flutter project
cd Project/Frontend

# Check for connected devices
flutter devices

# Run on Android/iOS
flutter run

# Run in release mode
flutter run --release

# Run with debug logging
flutter run --verbose
```

---

## 📊 Implementation Status

### ✅ Phase 1-11: COMPLETE (100%)

| Phase | Description | Status | Completion |
|-------|-------------|--------|------------|
| **Phase 1** | Supabase Setup & Flutter Configuration | ✅ | 100% |
| **Phase 2** | Core Database Tables | ✅ | 100% |
| **Phase 3** | Social Tables | ✅ | 100% |
| **Phase 4** | Extended Features Tables | ✅ | 100% |
| **Phase 5** | Row Level Security (RLS) | ✅ | 100% |
| **Phase 6** | Database Functions & Triggers | ✅ | 100% |
| **Phase 7** | Storage Buckets | ✅ | 100% |
| **Phase 8** | Auth Service Implementation | ✅ | 100% |
| **Phase 9** | Phone/Email Verification | ✅ | 100% |
| **Phase 10** | Onboarding Flow | ✅ | 100% |
| **Phase 11** | Location Service | ⚠️ 95% | See below |

#### Phase 11 Status: 11/12 Complete

- ✅ Live location tracking working
- ❌ Location name showing at top of home screen (LocationHeaderWidget not integrated)
- ✅ Radar animation on app launch
- ✅ Location updates to Supabase every 50 meters
- ✅ Online/offline status auto-managed
- ✅ App lifecycle handled properly
- ✅ All database operations working

**Fix Required:** Integrate `LocationHeaderWidget` into `HomeScreen` to show location name.

---

## 🗄️ Database Schema

### Core Tables (29 Total)

| Table | Purpose | Key Fields |
|-------|---------|------------|
| **profiles** | User profiles | id, email, username, full_name, location_name, latitude, longitude, is_online |
| **waves** | Connection requests | sender_id, receiver_id, status, wave_type |
| **connections** | Accepted connections | user1_id, user2_id, connection_source |
| **groups** | Groups/Hives | name, category, latitude, longitude, member_count |
| **events** | Local events | title, event_type, starts_at, latitude, longitude |
| **stories** | 24h stories | user_id, media_url, expires_at |
| **messages** | Chat messages | conversation_id, sender_id, content, message_type |

### Key Functions

```sql
check_username_available(p_username)
get_nearby_users(p_lat, p_lng, p_radius, p_user_id)
update_user_location(p_user_id, p_lat, p_lng, p_loc_name)
set_user_online_status(p_user_id, p_is_online)
accept_wave(p_wave_id, p_user_id)
get_user_stats(p_user_id)
```

### Realtime Tables

- `messages` - Real-time chat updates
- `conversations` - Conversation list updates
- `waves` - New wave notifications
- `notifications` - Push notifications
- `profiles` - Online status updates
- `stories` - New story alerts

---

## 📱 Testing

### Test Onboarding Flow

1. **Run the app:** `flutter run`
2. **Sign up** with email/password
3. **Complete onboarding:**
   - Step 1: Welcome screen
   - Step 2: Add profile photo, name, username, DOB, gender
   - Step 3: Select 3+ interests
   - Step 4: Grant location permission
   - Step 5: Click "Start Exploring"
4. **Verify:**
   - ✅ Onboarding saves successfully
   - ✅ Navigates to home screen
   - ✅ Location loading animation shows
   - ✅ Home screen displays nearby users

### Verify Database

Check Supabase Dashboard:

1. **Table Editor:**
   - Go to Table Editor → `profiles`
   - Your user record should have:
     - `onboarding_completed: true`
     - `latitude` and `longitude` populated
     - `location_name: "Location Set"`

2. **Storage:**
   - Go to Storage → `avatars`
   - Your uploaded avatar should be visible

### Debug Logs

Expected console output:

```
🔍 Checking onboarding status for user: [user-id]
📊 Onboarding status from DB: false
⚠️ User has NOT completed onboarding
[Complete onboarding]
🔄 Starting onboarding completion...
📊 Save result: true, onboardingComplete: true
✅ Onboarding saved successfully! Popping to AuthWrapper...
🔍 Checking onboarding status for user: [user-id]
📊 Onboarding status from DB: true
✅ User has completed onboarding, starting location fetching...
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. PostgrestException: "could not find column 'location'"

**Cause:** Column name mismatch (database has `location_name`, not `location`)

**Fix:** Already fixed in commit `435613c`. Pull latest changes:
```bash
git pull origin master
```

#### 2. "Failed to save profile" Error

**Cause:** Database schema not created

**Fix:** Run `QUICK_DATABASE_SETUP.sql` in Supabase SQL Editor (see Step 4)

#### 3. Location Permission Denied

**Fix:** The app handles this gracefully with retry UI. Click "Open Settings" to grant permission.

#### 4. "Nothing happens" after onboarding

**Fix:** Already fixed in commit `435613c`. The app now properly:
- Saves onboarding data
- Pops back to AuthWrapper
- Re-checks onboarding status
- Navigates to home

#### 5. Flutter Dependencies Issues

```bash
# Clean and reinstall
flutter clean
flutter pub get
flutter pub upgrade
```

#### 6. Supabase Connection Issues

**Check:**
- Supabase URL and anon key are correct
- Internet connection is working
- Supabase project is not paused (free tier pauses after 7 days inactive)

**Test connection:**
```bash
curl https://YOUR_PROJECT_REF.supabase.co/rest/v1/ \
  -H "apikey: YOUR_ANON_KEY"
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Write meaningful commit messages
- Add tests for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) - Backend as a Service
- [Flutter](https://flutter.dev) - UI framework
- [Geolocator](https://pub.dev/packages/geolocator) - Location services
- [Provider](https://pub.dev/packages/provider) - State management

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/devamsshinde/colony-app/issues)
- **Discussions:** [GitHub Discussions](https://github.com/devamsshinde/colony-app/discussions)
- **Email:**支持的电子邮件地址 (if available)

---

## 🗓️ Roadmap

### Phase 12: Home Screen (Up Next)
- Display nearby users list
- Show location header with current location name
- Search functionality
- Pull-to-refresh

### Phase 13-15: Chat & Messaging
- Real-time messaging with WebSockets
- Message reactions
- Voice notes
- Media sharing

### Phase 16-18: Groups & Events
- Create/manage groups
- Event creation and RSVP
- Group chat
- Location-based discovery

### Phase 19-21: Gamification
- Karma points system
- Achievement badges
- Daily streaks
- Colony levels

### Phase 22-24: Premium Features
- Subscription management
- Boosted profiles
- Ghost mode
- Extended radius

---

<div align="center">

**Built with ❤️ using Flutter & Supabase**

**⭐ Star us on GitHub — it helps!**

[⬆ Back to Top](#-colony---location-based-social-community-app)

</div>
