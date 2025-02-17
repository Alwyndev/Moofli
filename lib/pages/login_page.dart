import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:moofli_app/components/google_login_button.dart';
import 'package:moofli_app/components/gradient_button.dart';
// import 'package:moofli_app/components/secrets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  bool status = true;
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
            'googleUser',
            jsonEncode({
              'name': googleUser.displayName,
              'email': googleUser.email,
              'photoUrl': googleUser.photoUrl,
            }));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (error) {
      _showErrorDialog("Error during Google Sign-In: $error");
    }
  }

  Future<void> login(BuildContext context) async {
    final String email = usernameController.text.trim();
    final String password = passwdController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);
    final Uri url = Uri.parse('http://93.127.172.217:2004/api/user/login');
    // print(url);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', responseData['token']);
        print(responseData['token']);
        await prefs.setString(
            'userDetails', jsonEncode(responseData['result']));
        print(responseData['result']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(errorData['message'] ?? 'Login failed');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error during login: $error');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Login Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'LOGIN',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue
                  ]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwdController,
                obscureText: status,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => status = !status),
                    icon:
                        Icon(status ? Icons.visibility_off : Icons.visibility),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reset_password'),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      text: 'Log In',
                      onPressed: () => login(context),
                      border: 20,
                      padding: 16,
                    ),
              const SizedBox(height: 10),
              const Center(child: Text('Not Registered Yet?')),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromRGBO(167, 166, 166, 1),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromRGBO(167, 166, 166, 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: GoogleLoginButton(onPressed: _handleGoogleLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
