# Colony - Community Social App

A Flutter-based community social networking application with Supabase backend.

## 🚀 Features

- **Authentication System**
  - Email/Password signup and login
  - Phone OTP verification
  - Email verification
  - Secure session management
  - Device tracking and limits

- **User Profiles**
  - Custom usernames
  - Profile pictures
  - Online status tracking

- **Community Features**
  - Colony membership
  - Events management
  - Community chat
  - Photo gallery

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: Provider + StateNotifier

## 📁 Project Structure

```
Colony O/
├── Project/
│   ├── Frontend/           # Flutter application
│   │   ├── lib/
│   │   │   ├── core/       # Core utilities, configs, constants
│   │   │   ├── features/   # Feature-based modules
│   │   │   │   ├── auth/   # Authentication feature
│   │   │   │   ├── chat/   # Chat feature
│   │   │   │   ├── events/ # Events feature
│   │   │   │   └── ...
│   │   │   └── screens/    # App screens
│   │   └── assets/         # Animations, images, fonts
│   │
│   ├── backend/            # Node.js backend (optional)
│   │
│   └── supabase/
│       └── sql/            # Database schema and migrations
│
└── supabase/               # Supabase configuration
```

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Supabase account
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/colony-app.git
   cd colony-app
   ```

2. **Install Flutter dependencies**
   ```bash
   cd Project/Frontend
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Run the SQL migrations in `Project/supabase/sql/`
   - Update Supabase credentials in `lib/core/constants/supabase_constants.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔐 Environment Variables

Create a `.env` file in the backend directory (if using Node.js backend):

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## 🧪 Development Mode

The app includes a developer bypass for testing:

- **Dev OTP Code**: `949294` (use this for phone verification in debug mode)
- **Email Bypass**: Tap "Skip Verification (Dev Mode)" button

> ⚠️ These bypasses only work in debug mode and are disabled in release builds.

## 📊 Database Schema

The app uses 29 tables including:

- `profiles` - User profiles
- `colonies` - Community groups
- `colony_members` - Membership management
- `events` - Community events
- `messages` - Chat messages
- `posts` - Social posts
- And more...

See `Project/supabase/sql/` for complete schema.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Authors

- Development Team

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [Provider](https://pub.dev/packages/provider)
