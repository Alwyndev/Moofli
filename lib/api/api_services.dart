// lib/api/api_services.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A centralized service for making all HTTP calls to https://skillop.in/api
class ApiService {
  /// Base URL for the Skillop API
  static const String _baseUrl = 'https://skillop.in/api';

  /// Common headers to ask the server to return JSON
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Wraps a raw token with "Bearer "
  static String _bearer(String token) => 'Bearer $token';

  ///
  /// USER AUTH & PROFILE
  ///

  /// Registers a new user.
  ///
  /// Endpoint: POST https://skillop.in/api/user/register
  /// Body JSON: { "email", "password", "firstname", "lastname" }
  /// Returns: JSON with keys { "token": String, "result": {…user…}, "message": String }
  static Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/user/register');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          "email": email,
          "password": password,
          // "firstname": firstname,
          // "lastname": lastname,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          if (kDebugMode) {
            debugPrint(
              'registerUser: Expected JSON but got: $contentType\n'
              'Response (truncated): ${response.body.substring(0, response.body.length.clamp(0, 200))}',
            );
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'registerUser failed [${response.statusCode}]: ${response.body}',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in registerUser: $e');
      return null;
    }
  }

  /// Logs in an existing user.
  ///
  /// Endpoint: POST https://skillop.in/api/user/login
  /// Body JSON: { "email", "password" }
  /// Returns: JSON with keys { "token": String, "result": {…user…}, "message": String }
  static Future<Map<String, dynamic>?> userLogin({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/user/login');
    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          if (kDebugMode) {
            debugPrint(
              'userLogin: Expected JSON but got: $contentType\n'
              'Response (truncated): ${response.body.substring(0, response.body.length.clamp(0, 200))}',
            );
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              'userLogin failed [${response.statusCode}]: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in userLogin: $e');
      return null;
    }
  }

  /// Fetches the authenticated user’s full profile.
  ///
  /// ⚠ **IMPORTANT**: The correct endpoint is `/user/profile/me` (​_not_ `/user/get-profile`).
  ///   GET https://skillop.in/api/user/profile/me
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: JSON object representing the user’s profile.
  static Future<Map<String, dynamic>?> fetchProfile(String token) async {
    final Uri url = Uri.parse('$_baseUrl/user/profile/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': _bearer(token),
        },
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          // HTML or something unexpected
          if (kDebugMode) {
            debugPrint(
              'fetchProfile: Expected JSON but got: $contentType\n'
              'Response (truncated): ${response.body.substring(0, response.body.length.clamp(0, 200))}',
            );
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'fetchProfile failed [${response.statusCode}]: ${response.body}',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in fetchProfile: $e');
      return null;
    }
  }

  /// Updates a single field in the user’s profile.
  ///
  /// Endpoint: PUT https://skillop.in/api/user/profile/update/{field}
  ///   – Path param “{field}” can be “firstname”, “lastname”, or “email”
  /// Body JSON: { "<field>": "<newValue>" }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> updateProfileField(
    String token,
    String field,
    String value,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/user/profile/update/$field');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode({field: value}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'updateProfileField("$field") failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in updateProfileField: $e');
      return false;
    }
  }

  /// Updates multiple fields in the user’s profile in one request.
  ///
  /// Endpoint: PUT https://skillop.in/api/user/profile/update
  /// Body JSON: { …all fields to update… }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: JSON with success details on HTTP 200/201.
  /// Updates multiple fields in the user's profile in one request
  static Future<bool> updateMultipleProfileFields(
    String token,
    Map<String, dynamic> updatedData,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/user/profile/update');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode(updatedData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode)
        debugPrint('Exception in updateMultipleProfileFields: $e');
      return false;
    }
  }

  /// Updates experience entries
  static Future<bool> updateExperience(
    String token,
    List<Map<String, dynamic>> experiences,
  ) async {
    return await updateMultipleProfileFields(token, {'experence': experiences});
  }

  /// Deletes an education entry
  static Future<bool> deleteEducation(
      String token, String id, String type) async {
    final Uri url = Uri.parse('$_baseUrl/user/$type/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': _bearer(token),
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in deleteEducation: $e');
      return false;
    }
  }

  /// Uploads a profile photo (or cover photo).
  ///
  /// Endpoint: POST https://skillop.in/api/user/profile/photo
  /// Form‐Data fields:
  ///   • type: “profile” or “cover”
  ///   • photo: file
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> uploadPhoto(
    String token,
    String photoPath,
    String type,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/user/profile/photo');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = _bearer(token);
      request.headers['Accept'] = 'application/json';
      request.fields['type'] = type;
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'uploadPhoto failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in uploadPhoto: $e');
      return false;
    }
  }

  ///
  /// EDUCATION / EXPERIENCE / SKILLS
  ///

  /// Adds a new education entry.
  ///
  /// Endpoint: POST https://skillop.in/api/user/education/add
  /// Body JSON: { "degree": String, "institution": String }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> addEducation(
    String token,
    Map<String, dynamic> education,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/user/education/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode(education),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'addEducation failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in addEducation: $e');
      return false;
    }
  }

  /// Deletes an existing education entry by its ID.
  ///
  /// Endpoint: DELETE https://skillop.in/api/user/education/{id}
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: HTTP 200/201 on success.
  // static Future<bool> deleteEducation(String token, String id, String s) async {
  //   final Uri url = Uri.parse('$_baseUrl/user/education/$id');
  //   try {
  //     final response = await http.delete(
  //       url,
  //       headers: {
  //         'Authorization': _bearer(token),
  //         'Accept': 'application/json',
  //       },
  //     );
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //           'deleteEducation failed [${response.statusCode}]: ${response.body}',
  //         );
  //       }
  //       return false;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) debugPrint('Exception in deleteEducation: $e');
  //     return false;
  //   }
  // }

  /// Adds a new experience entry.
  ///
  /// Endpoint: POST https://skillop.in/api/user/experience/add
  /// Body JSON: { "role": String, "company": String }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> addExperience(
    String token,
    Map<String, dynamic> experience,
  ) async {
    final Uri url = Uri.parse('$_baseUrl/user/experience/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode(experience),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'addExperience failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in addExperience: $e');
      return false;
    }
  }

  /// Deletes an existing experience entry by its ID.
  ///
  /// Endpoint: DELETE https://skillop.in/api/user/experience/{id}
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> deleteExperience(String token, String id) async {
    final Uri url = Uri.parse('$_baseUrl/user/experience/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': _bearer(token),
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'deleteExperience failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in deleteExperience: $e');
      return false;
    }
  }

  /// Adds a new skill.
  ///
  /// Endpoint: POST https://skillop.in/api/user/skills/add
  /// Body JSON: { "skill": String }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> addSkill(String token, String skill) async {
    final Uri url = Uri.parse('$_baseUrl/user/skills/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode({"skill": skill}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'addSkill failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in addSkill: $e');
      return false;
    }
  }

  /// Deletes a skill by its ID (or skill name).
  ///
  /// Endpoint: DELETE https://skillop.in/api/user/skills/{id}
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: HTTP 200/201 on success.
  static Future<bool> deleteSkill(String token, String id) async {
    final Uri url = Uri.parse('$_baseUrl/user/skills/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': _bearer(token),
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'deleteSkill failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in deleteSkill: $e');
      return false;
    }
  }

  ///
  /// DIARY (JOURNAL) ENTRIES
  ///

  /// Fetches all diary entries for the authenticated user.
  ///
  /// Endpoint: GET https://skillop.in/api/diary/entries
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: { "entries": [ … ] } on HTTP 200.
  static Future<List<dynamic>> fetchDiaryEntries(String token) async {
    final Uri url = Uri.parse('$_baseUrl/diary/entries');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': _bearer(token),
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          final Map<String, dynamic> jsonMap = jsonDecode(response.body);
          return (jsonMap['entries'] as List<dynamic>?) ?? [];
        } else {
          if (kDebugMode) {
            debugPrint(
              'fetchDiaryEntries: Expected JSON but got: $contentType\n'
              'Response (truncated): ${response.body.substring(0, response.body.length.clamp(0, 200))}',
            );
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            'fetchDiaryEntries failed [${response.statusCode}]: ${response.body}',
          );
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in fetchDiaryEntries: $e');
      return [];
    }
  }

  /// Creates a new diary entry.
  ///
  /// Endpoint: POST https://skillop.in/api/diary/create
  /// Body JSON: { "content": String, "title": String? }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: { "success": bool, "message": String, "entry": {…} }
  static Future<Map<String, dynamic>> createDiaryEntry({
    required String token,
    required String content,
    String? title,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/diary/create');
    try {
      final body = <String, dynamic>{"content": content};
      if (title != null && title.isNotEmpty) {
        body["title"] = title;
      }
      final response = await http.post(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode(body),
      );
      return {
        'success': (response.statusCode == 200 || response.statusCode == 201),
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception in createDiaryEntry: $e',
        'statusCode': 500,
      };
    }
  }

  /// Updates an existing diary entry by its ID.
  ///
  /// Endpoint: PUT https://skillop.in/api/diary/entries/{id}
  /// Body JSON: { "content": String, "title": String? }
  /// Header: { Authorization: "Bearer <token>", Content-Type: application/json }
  /// Returns: { "success": bool, "message": String, "entry": {…} }
  static Future<Map<String, dynamic>> updateDiaryEntry({
    required String token,
    required String entryId,
    required String content,
    String? title,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/diary/entries/$entryId');
    try {
      final body = <String, dynamic>{"content": content};
      if (title != null && title.isNotEmpty) {
        body["title"] = title;
      }
      final response = await http.put(
        url,
        headers: {
          'Authorization': _bearer(token),
          ..._jsonHeaders,
        },
        body: jsonEncode(body),
      );
      return {
        'success': (response.statusCode == 200 || response.statusCode == 201),
        'message': response.body,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception in updateDiaryEntry: $e',
        'statusCode': 500,
      };
    }
  }

  /// Deletes an existing diary entry by its ID.
  ///
  /// Endpoint: DELETE https://skillop.in/api/diary/entries/{id}
  /// Header: { Authorization: "Bearer <token>" }
  /// Returns: HTTP 200/204 on success.
  static Future<bool> deleteDiaryEntry(String token, String entryId) async {
    final Uri url = Uri.parse('$_baseUrl/diary/entries/$entryId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': _bearer(token),
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
            'deleteDiaryEntry failed [${response.statusCode}]: ${response.body}',
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Exception in deleteDiaryEntry: $e');
      return false;
    }
  }
}
