import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL can be updated if needed.
  static const String baseUrl = 'https://skillop.in/api';

  /// Registers a new user.
  static Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    final url = Uri.parse('$baseUrl/user/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "firstname": firstname,
        "lastname": lastname,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  /// Updates a single field on the profile.
  static Future<bool> updateProfileField(String field, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    // Map 'pastExperience' to the key expected by the API
    String fieldKey = (field == 'pastExperience') ? 'pastExp' : field;
    var uri = Uri.parse("$baseUrl/user/update/profile");
    var request = http.MultipartRequest("PUT", uri);
    request.headers['Authorization'] = token;
    request.fields[fieldKey] = value;

    try {
      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Updates multiple fields at once.
  static Future<bool> updateMultipleProfileFields(
      Map<String, String> fields) async {
    bool allUpdated = true;
    for (var entry in fields.entries) {
      bool updated = await updateProfileField(entry.key, entry.value);
      if (!updated) {
        allUpdated = false;
      }
    }
    return allUpdated;
  }

  /// Uploads a photo (cover or profile) to the backend.
  static Future<bool> uploadPhoto(String photoPath, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    Uri uri;
    http.MultipartRequest request;

    if (type == 'cover') {
      uri = Uri.parse('$baseUrl/user/add/boackgroundPic');
      request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('profileBackgroundPic', photoPath),
      );
    } else if (type == 'profile') {
      uri = Uri.parse('$baseUrl/user/update/profile');
      request = http.MultipartRequest('PUT', uri);
      request.files.add(
        await http.MultipartFile.fromPath('profilePic', photoPath),
      );
    } else {
      return false;
    }

    request.headers['Authorization'] = token;
    final response = await request.send();
    return response.statusCode == 200;
  }
}
