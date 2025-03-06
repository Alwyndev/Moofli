import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moofli_app/components/gradient_button.dart';

class ResetPasswordPage extends StatefulWidget {
  // If token is provided, the page will be in reset mode.
  final String? token;
  const ResetPasswordPage({Key? key, this.token}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Base URL constant
  static const String baseUrl = 'https://skillop.in/api';

  // Function to call the forget password API.
  Future<void> _sendForgetPassword() async {
    final email = _controller.text;
    final url = '$baseUrl/user/password/forget';
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to call the reset password API.
  Future<void> _resetPassword() async {
    final password = _controller.text;
    final token = widget.token;
    if (token == null) return;
    final url = '$baseUrl/user/password/reset/$token';
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset password.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the mode based on whether a token is passed.
    final isResetMode = widget.token != null;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    isResetMode ? 'RESET PASSWORD' : 'FORGOT PASSWORD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Decorative Line
                  Container(
                    height: 8,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Input Field: shows Email or New Password based on mode.
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: isResetMode ? 'New Password' : 'Email',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    // Hide input text in reset mode for password security.
                    obscureText: isResetMode,
                  ),
                  SizedBox(height: 40),
                  // Gradient Button to trigger the API call.
                  GradientButton(
                    text: isResetMode ? 'Reset Password' : 'Send Mail',
                    onPressed: () {
                      if (isResetMode) {
                        _resetPassword();
                      } else {
                        _sendForgetPassword();
                      }
                    },
                    border: 20,
                    padding: 13,
                  ),
                ],
              ),
      ),
    );
  }
}
