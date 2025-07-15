// lib/auth_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Model to hold authentication state.
class AuthState {
  final bool isLoggedIn;
  final String token;
  final Map<String, dynamic>? userDetails;

  AuthState({
    required this.isLoggedIn,
    required this.token,
    this.userDetails,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    Map<String, dynamic>? userDetails,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      userDetails: userDetails ?? this.userDetails,
    );
  }
}

const String baseUrl =
    'https://your-api-url.com'; // Replace with your actual base URL

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(isLoggedIn: false, token: '', userDetails: null)) {
    _loadFromPrefs();
  }

  /// Load token & userDetails from SharedPreferences (if they exist).
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token') ?? '';
    final userJson = prefs.getString('userDetails');

    if (storedToken.isNotEmpty && userJson != null) {
      final parsedUser = jsonDecode(userJson) as Map<String, dynamic>;
      state = AuthState(
          isLoggedIn: true, token: storedToken, userDetails: parsedUser);
    }
  }

  /// Call after successful login/signup.
  /// Persists token & userDetails to SharedPreferences and updates state.
  Future<void> login(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = userData['token'] as String;
    await prefs.setString('token', token);
    await prefs.setString('userDetails', jsonEncode(userData));
    state = AuthState(isLoggedIn: true, token: token, userDetails: userData);
  }

  /// Update only the userDetails portion (e.g., after editing profile).
  Future<void> updateUserDetails(Map<String, dynamic> newDetails) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDetails', jsonEncode(newDetails));
    state = state.copyWith(userDetails: newDetails);
  }

  /// Clear everything on logout.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState(isLoggedIn: false, token: '', userDetails: null);
  }

  /// Fetch user profile from API and update userDetails.
  Future<bool> getUserProfile() async {
    try {
      if (state.token.isEmpty) {
        print('No token available for fetching user profile');
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'), // Replace with your actual endpoint
        headers: {
          'Authorization': 'Bearer ${state.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body) as Map<String, dynamic>;
        await updateUserDetails(userData);
        return true;
      } else {
        print('Failed to fetch user profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return false;
    }
  }
}

/// The global provider for authentication.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
