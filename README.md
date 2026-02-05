# Tractor Mitra 🚜

A Flutter application for connecting farmers with tractor owners - book tractors for farming needs.

## Features

- 👨‍🌾 **Farmer Dashboard**: Browse and book available tractors
- 🏭 **Owner Dashboard**: Manage tractors and bookings
- ⭐ **Reviews & Ratings**: Rate and review tractors
- 📸 **Image Upload**: Add tractor images
- 💳 **Payment Integration**: Razorpay integration ready
- 🌐 **Multi-platform**: Web, Android, iOS support
- 🚀 **Pure Dart Backend**: No Python/Django required!

## Project Structure

```
tractor_mitra/
├── lib/                    # Flutter app source code
│   ├── screens/           # App screens
│   ├── services/          # API service layer
│   ├── widgets/           # Reusable widgets
│   ├── models/            # Data models
│   └── backend/           # Pure Dart backend server
│       ├── models/        # Backend data models
│       ├── database/      # SQLite database service
│       ├── handlers/      # API route handlers
│       └── server.dart    # Server configuration
├── bin/                   # Backend startup scripts
└── assets/                # Images and assets
```

## Setup Instructions

### Backend Setup (Pure Dart)

The backend is now written entirely in Dart! No Python or Django needed.

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Start the backend server:**
   ```bash
   # Option 1: Using Dart
   dart run bin/start_backend.dart
   
   # Option 2: Direct run
   dart lib/backend/main_server.dart
   ```

   Backend will be available at: `http://127.0.0.1:8000/api/`

### Flutter App Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run
   
   # iOS
   flutter run
   ```

## Backend API Endpoints

- `GET /api/tractors/` - List available tractors
- `POST /api/tractors/add/` - Add new tractor
- `GET /api/bookings/` - List all bookings
- `POST /api/bookings/` - Create booking
- `POST /api/bookings/complete/<id>/` - Complete booking
- `GET /api/reviews/<tractor_id>/` - Get reviews
- `POST /api/reviews/add/` - Add review

## Advantages of Pure Dart Backend

✅ **Single Language**: Entire project in Dart/Flutter  
✅ **No Python Required**: No Django/Python dependencies  
✅ **Fast Startup**: Quick server initialization  
✅ **Type Safe**: Shared types between frontend and backend  
✅ **Lightweight**: Lower memory footprint  
✅ **Easy Deployment**: Single codebase to maintain  

## Database

The SQLite database is automatically created at `data/tractor_mitra.db` when the backend starts.

Uploaded images are stored in `data/media/tractors/`

## Requirements

- Flutter SDK 3.10.4+
- Dart SDK 3.10.4+

For detailed backend documentation, see [README_BACKEND_DART.md](README_BACKEND_DART.md)
