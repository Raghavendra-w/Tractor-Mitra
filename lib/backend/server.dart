import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_static/shelf_static.dart';
import 'database/database_service.dart';
import 'handlers/tractor_handler.dart';
import 'handlers/booking_handler.dart';
import 'handlers/review_handler.dart';

class Server {
  final int port;
  final String host;
  HttpServer? _server;

  Server({this.port = 8000, this.host = '0.0.0.0'});

  Future<void> start() async {
    // Initialize database
    await DatabaseService.instance.initialize();
    
    final tractorHandler = TractorHandler();
    final bookingHandler = BookingHandler();
    final reviewHandler = ReviewHandler();
    
    // Serve static media files
    final mediaHandler = createStaticHandler(
      'data/media',
      defaultDocument: 'index.html',
    );
    
    // Main request handler
    FutureOr<Response> mainHandler(Request request) async {
      final path = request.url.path;
      
      // Media files
      if (path.startsWith('media/')) {
        return mediaHandler(request);
      }
      
      // Tractor routes
      if (path.startsWith('api/tractors')) {
        return tractorHandler.router(request);
      }
      
      // Booking routes
      if (path.startsWith('api/bookings')) {
        return bookingHandler.router(request);
      }
      
      // Review routes
      if (path.startsWith('api/reviews')) {
        return reviewHandler.router(request);
      }
      
      return Response.notFound('Not found');
    }
    
    // CORS middleware
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders())
        .addHandler(mainHandler);
    
    // Start server
    _server = await io.serve(
      handler,
      host,
      port,
    );
    
    print('🚀 Tractor Mitra Backend Server running on http://$host:$port');
    print('📡 API available at http://$host:$port/api/');
  }

  Future<void> stop() async {
    await _server?.close();
    DatabaseService.instance.close();
    print('🛑 Server stopped');
  }
}
