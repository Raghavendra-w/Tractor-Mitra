import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// ============================
/// 🌐 API SERVICE
/// ============================
class ApiService {
  /// Web → http://127.0.0.1:8000
  /// Android Emulator → http://10.0.2.2:8000
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static const Duration requestTimeout = Duration(seconds: 30);

  // ==================================================
  // 🔐 OWNER AUTH (OTP)
  // ==================================================

  static Future<void> sendOtp(String mobile) async {
    final res = await http.post(
      Uri.parse("$baseUrl/send-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile}),
    );

    if (res.statusCode != 200) {
      throw ConnectionException("Failed to send OTP");
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String mobile,
    String otp,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "otp": otp}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Invalid OTP");
  }

  // ==================================================
  // 📊 OWNER DASHBOARD
  // ==================================================

  static Future<Map<String, dynamic>> getWeeklyStats(int ownerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/owners/$ownerId/weekly-stats/"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load weekly stats");
  }

  static Future<List<dynamic>> getUpcomingBookings(int ownerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/owners/$ownerId/upcoming-bookings/"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load upcoming bookings");
  }

  static Future<Map<String, dynamic>> getOwnerEarnings(int ownerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/owners/$ownerId/total-earnings/"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load earnings");
  }

  // ==================================================
  // 🚜 TRACTORS
  // ==================================================

  static Future<List<dynamic>> getTractors() async {
    final res = await http.get(Uri.parse("$baseUrl/tractors/"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load tractors");
  }

  static Future<List<dynamic>> getOwnerTractors(int ownerId) async {
    final res = await http.get(Uri.parse("$baseUrl/owners/$ownerId/tractors/"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load owner tractors");
  }

  static Future<List<dynamic>> getAvailableByCategory(String category) async {
    final res = await http.get(
      Uri.parse("$baseUrl/tractors/?category=$category"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load category tractors");
  }

  // ➕ ADD TRACTOR (FINAL – MATCHES UI)
  static Future<void> addTractorWithImage({
    required int ownerId,
    required String name,
    required String category,
    required int pricePerHour,
    required String model,
    required int year,
    required String registrationNumber,
    required String chassisNumber,
    required bool insured,
    required bool available,
    XFile? image,
  }) async {
    print("ADDING TRACTOR FOR OWNER = $ownerId");

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/tractors/add/"),
    );

    request.fields.addAll({
      "owner": ownerId.toString(), // ✅ MUST BE "owner"
      "name": name,
      "category": category,
      "price_per_hour": pricePerHour.toString(),
      "model": model,
      "year": year.toString(),
      "registration_number": registrationNumber,
      "chassis_number": chassisNumber,
      "insured": insured ? "true" : "false",
      "available": available ? "true" : "false",
    });

    if (image != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          await image.readAsBytes(),
          filename: image.name,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print("ADD TRACTOR RESPONSE = ${response.statusCode}");
    print(body);
    if (response.statusCode != 201) {
      throw Exception("Add tractor failed: $body");
    }
  }

  // 🔁 TOGGLE TRACTOR AVAILABILITY
  static Future<void> toggleTractorAvailability({
    required int tractorId,
    required bool available,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/tractors/$tractorId/toggle/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"available": available}),
    );

    if (response.statusCode != 200) {
      throw _handleHttpError(response.statusCode, response.body);
    }
  }

  // ==================================================
  // 🛠 EQUIPMENTS
  // ==================================================

  static Future<void> addEquipment({
    required int tractorId,
    required String name,
    required int pricePerHour,
    XFile? image,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/equipments/add/"),
    );

    request.fields.addAll({
      "tractor": tractorId.toString(),
      "name": name,
      "price_per_hour": pricePerHour.toString(),
    });

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("image", image.path));
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw ConnectionException("Failed to add equipment");
    }
  }

  // ==================================================
  // 📅 BOOKINGS
  // ==================================================

  static Future<List<dynamic>> getBookings() async {
    final res = await http.get(Uri.parse("$baseUrl/bookings/"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load bookings");
  }

  static Future<void> createBooking({
    required int tractorId,
    required int hours,
    required int totalAmount,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/bookings/create/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tractor": tractorId,
        "hours": hours,
        "total_price": totalAmount,
      }),
    );

    if (res.statusCode != 201) {
      throw ConnectionException("Booking failed");
    }
  }

  static Future<void> completeBooking(int bookingId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/bookings/complete/$bookingId/"),
    );

    if (res.statusCode != 200) {
      throw ConnectionException("Failed to complete booking");
    }
  }

  // ==================================================
  // ⭐ REVIEWS
  // ==================================================

  static Future<List<dynamic>> getReviews(int tractorId) async {
    final res = await http.get(Uri.parse("$baseUrl/reviews/$tractorId/"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw ConnectionException("Failed to load reviews");
  }

  static Future<void> addReview({
    required int tractorId,
    required int rating,
    required String comment,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/reviews/add/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tractor": tractorId,
        "rating": rating,
        "comment": comment,
      }),
    );

    if (res.statusCode != 201) {
      throw ConnectionException("Review failed");
    }
  }

  // ==================================================
  // 👤 OWNER PROFILE / ACCOUNT
  // ==================================================

  static Future<Map<String, dynamic>> getOwnerAccount(int ownerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/owner/profile/?owner_id=$ownerId"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load owner profile");
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getOwnerNotifications(int ownerId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/owners/$ownerId/notifications/"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load notifications");
    }

    return jsonDecode(response.body);
  }

  // ==================================================
  // 🔧 ERROR HANDLER
  // ==================================================

  static Exception _handleHttpError(int code, String message) {
    switch (code) {
      case 400:
        return ConnectionException("Bad request");
      case 401:
        return ConnectionException("Unauthorized");
      case 403:
        return ConnectionException("Forbidden");
      case 404:
        return ConnectionException("API not found");
      case 500:
        return ConnectionException("Server error");
      default:
        return ConnectionException(message);
    }
  }
  // ============================
  // ⚙️ APP PREFERENCES
  // ============================

  static Future<Map<String, dynamic>> getPreferences(int ownerId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/owners/$ownerId/preferences/"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load preferences");
    }

    return jsonDecode(res.body);
  }

  static Future<void> updatePreferences({
    required int ownerId,
    required bool notifications,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/owners/$ownerId/preferences/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"notifications": notifications}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update preferences");
    }
  }
}

/// ============================
/// ❌ CONNECTION EXCEPTION
/// ============================
class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}
