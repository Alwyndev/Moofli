import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:moofli_app/components/gradient_button.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? token;
  const ResetPasswordPage({Key? key, this.token}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _mailSent = false;
  bool _canResend = false;
  int _resendDelay = 30;
  Timer? _timer;

  static const String baseUrl = 'https://skillop.in/api';

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
        setState(() {
          _mailSent = true;
          _canResend = false;
          _startResendTimer();
        });
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

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendDelay > 0) {
        setState(() {
          _resendDelay--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  VoidCallback? _resendMailFunction() {
    if (!_canResend) return null;
    return () {
      setState(() {
        _resendDelay += 15;
        _canResend = false;
      });
      _startResendTimer();
      _sendForgetPassword();
    };
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    isResetMode ? 'RESET PASSWORD' : 'FORGOT PASSWORD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
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
                    obscureText: isResetMode,
                  ),
                  SizedBox(height: 20),
                  GradientButton(
                    text: _mailSent
                        ? 'Back to Login'
                        : (isResetMode ? 'Reset Password' : 'Send Mail'),
                    onPressed: () {
                      if (_mailSent) {
                        Navigator.pop(context);
                      } else if (isResetMode) {
                        _resetPassword();
                      } else {
                        _sendForgetPassword();
                      }
                    },
                    border: 20,
                    padding: 13,
                  ),
                  if (_mailSent) ...[
                    SizedBox(height: 10),
                    GradientButton(
                      text: _canResend
                          ? "Resend Mail"
                          : "Resend in $_resendDelay s",
                      onPressed: _resendMailFunction() ?? () {},
                      border: 20,
                      padding: 13,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
