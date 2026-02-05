import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';
import '../models/tractor_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  late Database _db;
  bool _initialized = false;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Get database path
    final dbPath = await _getDatabasePath();
    final dbFile = File(dbPath);
    
    // Create directory if it doesn't exist
    await dbFile.parent.create(recursive: true);

    _db = sqlite3.open(dbPath);
    _createTables();
    _initialized = true;
  }

  Future<String> _getDatabasePath() async {
    // For server environments, use current directory
    // Create a 'data' directory for database
    final dbDir = Directory('data');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return path.join(dbDir.path, 'tractor_mitra.db');
  }

  void _createTables() {
    // Create Tractors table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS tractors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price_per_hour INTEGER NOT NULL,
        available INTEGER NOT NULL DEFAULT 1,
        image TEXT
      )
    ''');

    // Create Bookings table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tractor INTEGER NOT NULL,
        hours INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (tractor) REFERENCES tractors(id)
      )
    ''');

    // Create Reviews table
    _db.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tractor INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (tractor) REFERENCES tractors(id)
      )
    ''');

    // Create indexes for performance
    _db.execute('CREATE INDEX IF NOT EXISTS idx_tractors_available ON tractors(available)');
    _db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at DESC)');
    _db.execute('CREATE INDEX IF NOT EXISTS idx_reviews_tractor ON reviews(tractor)');
  }

  // ==================== TRACTOR OPERATIONS ====================

  List<TractorModel> getTractors({bool? available}) {
    String query = 'SELECT * FROM tractors';
    if (available != null) {
      query += ' WHERE available = ${available ? 1 : 0}';
    }
    query += ' ORDER BY id';

    final result = _db.select(query);
    return result.map((row) => TractorModel(
      id: row['id'] as int,
      name: row['name'] as String,
      pricePerHour: row['price_per_hour'] as int,
      available: (row['available'] as int) == 1,
      image: row['image'] as String?,
    )).toList();
  }

  TractorModel? getTractorById(int id) {
    final result = _db.select('SELECT * FROM tractors WHERE id = ?', [id]);
    if (result.isEmpty) return null;

    final row = result.first;
    return TractorModel(
      id: row['id'] as int,
      name: row['name'] as String,
      pricePerHour: row['price_per_hour'] as int,
      available: (row['available'] as int) == 1,
      image: row['image'] as String?,
    );
  }

  int insertTractor(TractorModel tractor) {
    _db.execute(
      'INSERT INTO tractors (name, price_per_hour, available, image) VALUES (?, ?, ?, ?)',
      [
        tractor.name,
        tractor.pricePerHour,
        tractor.available ? 1 : 0,
        tractor.image,
      ],
    );
    return _db.lastInsertRowId;
  }

  void updateTractor(TractorModel tractor) {
    if (tractor.id == null) return;
    
    _db.execute(
      'UPDATE tractors SET name = ?, price_per_hour = ?, available = ?, image = ? WHERE id = ?',
      [
        tractor.name,
        tractor.pricePerHour,
        tractor.available ? 1 : 0,
        tractor.image,
        tractor.id,
      ],
    );
  }

  // ==================== BOOKING OPERATIONS ====================

  List<BookingModel> getBookings() {
    final result = _db.select('SELECT * FROM bookings ORDER BY created_at DESC');
    return result.map((row) => BookingModel(
      id: row['id'] as int,
      tractorId: row['tractor'] as int,
      hours: row['hours'] as int,
      totalPrice: row['total_price'] as int,
      completed: (row['completed'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    )).toList();
  }

  BookingModel? getBookingById(int id) {
    final result = _db.select('SELECT * FROM bookings WHERE id = ?', [id]);
    if (result.isEmpty) return null;

    final row = result.first;
    return BookingModel(
      id: row['id'] as int,
      tractorId: row['tractor'] as int,
      hours: row['hours'] as int,
      totalPrice: row['total_price'] as int,
      completed: (row['completed'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  int insertBooking(BookingModel booking) {
    _db.execute(
      'INSERT INTO bookings (tractor, hours, total_price, completed, created_at) VALUES (?, ?, ?, ?, ?)',
      [
        booking.tractorId,
        booking.hours,
        booking.totalPrice,
        booking.completed ? 1 : 0,
        booking.createdAt.toIso8601String(),
      ],
    );
    return _db.lastInsertRowId;
  }

  void updateBooking(BookingModel booking) {
    if (booking.id == null) return;
    
    _db.execute(
      'UPDATE bookings SET completed = ? WHERE id = ?',
      [booking.completed ? 1 : 0, booking.id],
    );
  }

  // ==================== REVIEW OPERATIONS ====================

  List<ReviewModel> getReviewsByTractorId(int tractorId) {
    final result = _db.select(
      'SELECT * FROM reviews WHERE tractor = ? ORDER BY created_at DESC',
      [tractorId],
    );
    return result.map((row) => ReviewModel(
      id: row['id'] as int,
      tractorId: row['tractor'] as int,
      rating: row['rating'] as int,
      comment: row['comment'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    )).toList();
  }

  int insertReview(ReviewModel review) {
    _db.execute(
      'INSERT INTO reviews (tractor, rating, comment, created_at) VALUES (?, ?, ?, ?)',
      [
        review.tractorId,
        review.rating,
        review.comment,
        review.createdAt.toIso8601String(),
      ],
    );
    return _db.lastInsertRowId;
  }

  ReviewModel? getReviewById(int id) {
    final result = _db.select('SELECT * FROM reviews WHERE id = ?', [id]);
    if (result.isEmpty) return null;

    final row = result.first;
    return ReviewModel(
      id: row['id'] as int,
      tractorId: row['tractor'] as int,
      rating: row['rating'] as int,
      comment: row['comment'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  void close() {
    _db.dispose();
    _initialized = false;
  }
}
