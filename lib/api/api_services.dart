import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://skillop.in/api';

  /// Registers a new user
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

  /// User login
  static Future<Map<String, dynamic>?> userLogin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/user/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> userData = jsonDecode(response.body);
      String token = userData['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userDetails', jsonEncode(userData));
      await prefs.setBool('isLoggedIn', true);
      return userData;
    } else {
      return null;
    }
  }

  /// Fetches diary entries
  static Future<List<dynamic>> fetchDiaryEntries(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/diary/entries'),
        headers: {'Authorization': token},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['entries'] ?? [];
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching diary entries: $e');
      return [];
    }
  }

  /// Creates a new diary entry
  static Future<Map<String, dynamic>> createDiaryEntry({
    required String token,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/diary/dairyCreate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({"content": content}),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'statusCode': 500,
      };
    }
  }

  /// Updates an existing diary entry
  static Future<Map<String, dynamic>> updateDiaryEntry({
    required String token,
    required String entryId,
    required String content,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/diary/dairyupdate/$entryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({"content": content}),
      );
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'statusCode': 500,
      };
    }
  }

  static Future<void> logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Logout'),
              content: Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmLogout) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      } catch (error) {
        if (kDebugMode) print('Logout error: $error');
      }
    }
  }

  static Future<void> deleteAccount(BuildContext context) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete Account"),
            content: Text("Are you sure you want to delete your account?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    final url = Uri.parse("https://skillop.in/api/delete");

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        url,
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Your account has been successfully deleted.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to delete account. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  /// Fetches user profile details.
  static Future<Map<String, dynamic>> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/profile/me"),
        headers: {'Authorization': '$token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching profile: $e');
      rethrow;
    }
  }

  static Future<bool> updateProfileField(String field, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    String fieldKey = (field == 'pastExperience') ? 'pastExp' : field;
    var uri = Uri.parse("$baseUrl/user/update/profile");
    var request = http.MultipartRequest("PUT", uri);
    request.headers['authorization'] = token;
    request.fields[fieldKey] = value;
    try {
      final streamedResponse = await request.send();
      return streamedResponse.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error updating profile field: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateMultipleProfileFields(
      Map<String, dynamic> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token missing',
        'statusCode': 401,
      };
    }
    var uri = Uri.parse("$baseUrl/user/update/profile");
    var request = http.MultipartRequest("PUT", uri);
    request.headers['authorization'] = token;
    for (var entry in updatedData.entries) {
      var key = entry.key;
      var value = entry.value;

      if (key == 'pastExperience') {
        key = 'pastExp';
        request.fields[key] = value.toString();
      } else if (key == 'experience') {
        key = 'experence';
        request.fields[key] = jsonEncode(value);
      } else if (key == 'profilePic') {
        try {
          request.files.add(
            await http.MultipartFile.fromPath('profilePic', value),
          );
        } catch (e) {
          if (kDebugMode) print('Error attaching profilePic: $e');
        }
      } else if ((key == 'skills' || key == 'education') && value is List) {
        request.fields[key] = jsonEncode(value);
      } else {
        request.fields[key] = value.toString();
      }
    }
    final response = await request.send();
    String responseString = await response.stream.bytesToString();
    return {
      'success': response.statusCode == 200,
      'message': responseString,
      'statusCode': response.statusCode,
    };
  }

  static Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    Map<String, dynamic> dataToSend = {};
    updatedData.forEach((key, value) {
      if (key == 'pastExperience') {
        dataToSend['pastExp'] = value.toString();
      } else if (key == 'experience') {
        dataToSend['experence'] = value;
      } else {
        dataToSend[key] = value;
      }
    });

    final response = await http.put(
      Uri.parse("$baseUrl/user/update/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: json.encode(dataToSend),
    );
    return response.statusCode == 200;
  }

  /// Uploads a photo (cover or profile).
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

  /// Adds a new education entry to the profile.
  static Future<bool> addEducation(Map<String, dynamic> education) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.put(
      Uri.parse("$baseUrl/user/update/profile/education"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: json.encode(education),
    );
    return response.statusCode == 200;
  }

  /// Deletes an education entry from the profile.
  /// Now accepts a String ID.
  static Future<bool> deleteEducation(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse("$baseUrl/user/remove/education/$id"),
      headers: {"Authorization": token},
    );
    return response.statusCode == 200;
  }

  /// Adds a new experience to the profile.
  static Future<bool> addExperience(Map<String, dynamic> experience) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.put(
      Uri.parse("$baseUrl/user/update/profile/experence"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: json.encode(experience),
    );
    return response.statusCode == 200;
  }

  /// Deletes an experience from the profile.
  /// Now accepts a String ID.
  static Future<bool> deleteExperience(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse("$baseUrl/user/remove/experence/$id"),
      headers: {"Authorization": token},
    );
    return response.statusCode == 200;
  }

  /// Adds a new skill to the profile.
  static Future<bool> addSkill(String skill) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.put(
      Uri.parse("$baseUrl/user/update/profile/skills"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      },
      body: json.encode({"skill": skill}),
    );
    return response.statusCode == 200;
  }

  /// Removes a skill from the profile.
  static Future<bool> deleteSkill(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse("$baseUrl/profile/skills/$id"),
      headers: {"Authorization": token},
    );
    return response.statusCode == 200;
  }
}
