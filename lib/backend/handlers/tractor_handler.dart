import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import '../database/database_service.dart';
import '../models/tractor_model.dart';

class TractorHandler {
  final DatabaseService _db = DatabaseService.instance;

  Handler get router {
    return (Request request) async {
      final path = request.url.path;
      
      if (request.method == 'GET' && (path == 'tractors/' || path == 'tractors')) {
        return _getTractors(request);
      } else if (request.method == 'POST' && path.contains('add')) {
        return _addTractor(request);
      }
      return Response.notFound('Not found');
    };
  }

  Future<Response> _getTractors(Request request) async {
    try {
      // Only return available tractors
      final tractors = _db.getTractors(available: true);
      final jsonList = tractors.map((t) => t.toJson()).toList();
      
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

  Future<Response> _addTractor(Request request) async {
    try {
      final contentType = request.headers['content-type'] ?? '';
      
      if (contentType.contains('multipart/form-data')) {
        return _addTractorWithImage(request);
      } else {
        return _addTractorJson(request);
      }
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addTractorJson(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      
      final tractor = TractorModel(
        name: json['name'] as String,
        pricePerHour: json['price_per_hour'] as int,
        available: json['available'] as bool? ?? true,
      );
      
      final id = _db.insertTractor(tractor);
      final created = _db.getTractorById(id);
      
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

  Future<Response> _addTractorWithImage(Request request) async {
    try {
      // Parse multipart form data
      final boundary = request.headers['content-type']?.split('boundary=')[1];
      if (boundary == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid multipart data'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.read().expand((chunk) => chunk).toList();
      final bodyBytes = Uint8List.fromList(body);
      final bodyString = utf8.decode(bodyBytes);
      
      // Simple multipart parser (for production, use a proper parser)
      final parts = _parseMultipart(bodyString, boundary);
      
      String? name;
      int? pricePerHour;
      String? imagePath;
      
      for (final part in parts) {
        if (part.containsKey('name')) {
          if (part['name'] == 'name') {
            name = part['value'] as String;
          } else if (part['name'] == 'price_per_hour') {
            pricePerHour = int.tryParse(part['value'] as String);
          } else if (part['name'] == 'image' && part.containsKey('file')) {
            // Save image file
            final imageBytes = part['file'] as List<int>;
            final mediaDir = Directory('data/media/tractors');
            if (!await mediaDir.exists()) {
              await mediaDir.create(recursive: true);
            }
            final fileName = 'tractor_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final file = File('${mediaDir.path}/$fileName');
            await file.writeAsBytes(imageBytes);
            imagePath = '/media/tractors/$fileName';
          }
        }
      }
      
      if (name == null || pricePerHour == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required fields'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      final tractor = TractorModel(
        name: name,
        pricePerHour: pricePerHour,
        available: true,
        image: imagePath,
      );
      
      final id = _db.insertTractor(tractor);
      final created = _db.getTractorById(id);
      
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

  List<Map<String, dynamic>> _parseMultipart(String body, String boundary) {
    // Simplified multipart parser
    final parts = <Map<String, dynamic>>[];
    final boundaryMarker = '--$boundary';
    final sections = body.split(boundaryMarker);
    
    for (final section in sections) {
      if (section.trim().isEmpty || section == '--') continue;
      
      final headerEnd = section.indexOf('\r\n\r\n');
      if (headerEnd == -1) continue;
      
      final headers = section.substring(0, headerEnd);
      final content = section.substring(headerEnd + 4);
      
      final part = <String, dynamic>{};
      
      // Parse Content-Disposition header
      final contentDispositionMatch = RegExp(r'name="([^"]+)"').firstMatch(headers);
      if (contentDispositionMatch != null) {
        part['name'] = contentDispositionMatch.group(1);
      }
      
      // Check if it's a file
      if (headers.contains('filename=')) {
        final fileMatch = RegExp(r'filename="([^"]+)"').firstMatch(headers);
        if (fileMatch != null) {
          part['filename'] = fileMatch.group(1);
          part['file'] = utf8.encode(content.trim().replaceAll('\r\n', ''));
        }
      } else {
        part['value'] = content.trim().replaceAll('\r\n', '');
      }
      
      if (part.isNotEmpty) {
        parts.add(part);
      }
    }
    
    return parts;
  }
}
