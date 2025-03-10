import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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

    // Map 'pastExperience' to the key expected by the API.
    String fieldKey = (field == 'pastExperience') ? 'pastExp' : field;
    var uri = Uri.parse("$baseUrl/profile");
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
      uri = Uri.parse('$baseUrl/profile');
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

  /// Fetches the user profile.
  static Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(Uri.parse("$baseUrl/profile"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  /// Updates the entire profile.
  static Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(updatedData),
    );
    return response.statusCode == 200;
  }

  /// Updates education details in the profile.
  static Future<bool> updateEducationDetails(
      List<Map<String, dynamic>> educationItems) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"education": educationItems}),
    );
    return response.statusCode == 200;
  }

  /// Adds a new experience to the profile.
  static Future<bool> addExperience(Map<String, String> experience) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/experience"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(experience),
    );
    return response.statusCode == 200;
  }

  /// Removes an experience from the profile.
  static Future<bool> deleteExperience(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/profile/experience/$id"));
    return response.statusCode == 200;
  }

  /// Adds a new skill to the profile.
  static Future<bool> addSkill(String skill) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/skills"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"skill": skill}),
    );
    return response.statusCode == 200;
  }

  /// Removes a skill from the profile.
  static Future<bool> deleteSkill(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/profile/skills/$id"));
    return response.statusCode == 200;
  }
}
