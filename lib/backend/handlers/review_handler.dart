import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../database/database_service.dart';
import '../models/review_model.dart';

class ReviewHandler {
  final DatabaseService _db = DatabaseService.instance;

  Handler get router {
    return (Request request) async {
      final path = request.url.path;
      
      if (request.method == 'GET' && !path.contains('add')) {
        // Extract tractor ID from path like "reviews/1"
        final segments = path.split('/');
        if (segments.isNotEmpty) {
          final tractorId = int.tryParse(segments.last);
          if (tractorId == null) {
            return Response.badRequest(
              body: jsonEncode({'error': 'Invalid tractor ID'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
          return _getReviews(request, tractorId);
        }
      } else if (request.method == 'POST' && path.contains('add')) {
        return _addReview(request);
      }
      return Response.notFound('Not found');
    };
  }

  Future<Response> _getReviews(Request request, int tractorId) async {
    try {
      final reviews = _db.getReviewsByTractorId(tractorId);
      final jsonList = reviews.map((r) => r.toJson()).toList();
      
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

  Future<Response> _addReview(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      
      final review = ReviewModel(
        tractorId: json['tractor'] as int,
        rating: json['rating'] as int,
        comment: json['comment'] as String,
      );
      
      final id = _db.insertReview(review);
      final created = ReviewModel(
        id: id,
        tractorId: review.tractorId,
        rating: review.rating,
        comment: review.comment,
        createdAt: review.createdAt,
      );
      
      return Response(
        201,
        body: jsonEncode(created.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
