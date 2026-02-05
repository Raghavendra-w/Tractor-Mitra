import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database_service.dart';
import '../models/booking_model.dart';

class BookingHandler {
  final DatabaseService _db = DatabaseService.instance;

  Handler get router {
    return (Request request) async {
      final path = request.url.path;
      
      if (request.method == 'GET' && path == 'bookings/') {
        return _getBookings(request);
      } else if (request.method == 'POST') {
        if (path.contains('complete')) {
          // Extract booking ID from path like "bookings/complete/1"
          final segments = path.split('/');
          if (segments.length >= 3) {
            final bookingId = int.tryParse(segments[2]);
            if (bookingId == null) {
              return Response.badRequest(
                body: jsonEncode({'error': 'Invalid booking ID'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
            return _completeBooking(request, bookingId);
          }
        }
        if (path == 'bookings/') {
          return _createBooking(request);
        }
      }
      return Response.notFound('Not found');
    };
  }

  Future<Response> _getBookings(Request request) async {
    try {
      final bookings = _db.getBookings();
      final jsonList = bookings.map((b) => b.toJson()).toList();
      
      return Response.ok(
        jsonEncode(jsonList),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createBooking(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      
      final tractorId = json['tractor'] as int;
      final hours = json['hours'] as int;
      final totalPrice = json['total_price'] as int;
      
      // Check if tractor exists and is available
      final tractor = _db.getTractorById(tractorId);
      if (tractor == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tractor not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      if (!tractor.available) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Tractor is not available'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // Create booking and lock tractor atomically
      final booking = BookingModel(
        tractorId: tractorId,
        hours: hours,
        totalPrice: totalPrice,
      );
      
      final bookingId = _db.insertBooking(booking);
      
      // Lock tractor
      final updatedTractor = tractor.copyWith(available: false);
      _db.updateTractor(updatedTractor);
      
      final created = _db.getBookingById(bookingId);
      
      return Response(
        201,
        body: jsonEncode(created!.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _completeBooking(Request request, int bookingId) async {
    try {
      final booking = _db.getBookingById(bookingId);
      if (booking == null) {
        return Response.notFound(
          body: jsonEncode({'error': 'Booking not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // Mark booking as completed and unlock tractor
      final updatedBooking = booking.copyWith(completed: true);
      _db.updateBooking(updatedBooking);
      
      final tractor = _db.getTractorById(booking.tractorId);
      if (tractor != null) {
        final updatedTractor = tractor.copyWith(available: true);
        _db.updateTractor(updatedTractor);
      }
      
      return Response.ok(
        jsonEncode({'message': 'Booking completed successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
