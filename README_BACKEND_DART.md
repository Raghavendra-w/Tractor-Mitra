# Tractor Mitra Backend - Pure Dart/Flutter

This backend is written entirely in Dart using the Shelf framework - no Python or Django required!

## Features

✅ Pure Dart/Flutter backend  
✅ SQLite database  
✅ RESTful API  
✅ CORS enabled  
✅ Image upload support  
✅ Fast and lightweight  

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the Backend Server

```bash
# Option 1: Using Dart directly
dart run bin/start_backend.dart

# Option 2: Run the server file directly
dart lib/backend/main_server.dart

# Option 3: In a separate terminal while Flutter app is running
```

The server will start on: `http://127.0.0.1:8000`

## API Endpoints

All endpoints are prefixed with `/api/`

### Tractors
- `GET /api/tractors/` - List all available tractors
- `POST /api/tractors/add/` - Add a new tractor (supports multipart/form-data for images)

### Bookings
- `GET /api/bookings/` - List all bookings
- `POST /api/bookings/` - Create a new booking
- `POST /api/bookings/complete/<id>/` - Complete a booking

### Reviews
- `GET /api/reviews/<tractor_id>/` - Get reviews for a tractor
- `POST /api/reviews/add/` - Add a review

## Database

The SQLite database is automatically created at `data/tractor_mitra.db` when the server starts.

Uploaded images are stored in `data/media/tractors/`

## Project Structure

```
lib/backend/
├── models/              # Data models
│   ├── tractor_model.dart
│   ├── booking_model.dart
│   └── review_model.dart
├── database/            # Database service
│   └── database_service.dart
├── handlers/            # API route handlers
│   ├── tractor_handler.dart
│   ├── booking_handler.dart
│   └── review_handler.dart
├── server.dart          # Main server configuration
└── main_server.dart     # Server entry point

bin/
└── start_backend.dart   # Startup script
```

## Running in Production

For production, you can compile to native code:

```bash
dart compile exe lib/backend/main_server.dart -o tractor_backend_server
./tractor_backend_server
```

## Advantages of Dart Backend

✅ Single language codebase (Dart/Flutter)  
✅ No need for Python/Django  
✅ Faster startup time  
✅ Lower memory footprint  
✅ Shared code between frontend and backend  
✅ Type-safe end-to-end  
