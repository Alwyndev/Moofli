import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://93.127.172.217:2004/api/user/profile/me"; // Replace with your API

  // Fetch user profile
  static Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.get(Uri.parse("$baseUrl/profile"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  // Update profile
  static Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(updatedData),
    );
    return response.statusCode == 200;
  }

  // Add experience
  static Future<bool> addExperience(Map<String, String> experience) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/experience"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(experience),
    );
    return response.statusCode == 200;
  }

  // Remove experience
  static Future<bool> deleteExperience(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/profile/experience/$id"));
    return response.statusCode == 200;
  }

  // Add skill
  static Future<bool> addSkill(String skill) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/skills"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"skill": skill}),
    );
    return response.statusCode == 200;
  }

  // Remove skill
  static Future<bool> deleteSkill(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/profile/skills/$id"));
    return response.statusCode == 200;
  }
}
