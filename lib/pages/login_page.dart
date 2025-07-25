// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// import 'package:moofli_app/components/google_login_button.dart';
import 'package:moofli_app/components/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';
import 'package:moofli_app/api/api_services.dart';

/// Create a GoogleSignIn instance. For mobile apps, you generally don't need
/// to specify a clientId. (For web you might need to.)
// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [
//     'email',
//     'profile',
//   ],
// );

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Instance for Google Sign-In.

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  bool status = true;
  bool _isLoading = false;

  // Method to handle Google Sign-In.
// Function to handle Google login.
  // Future<void> _showMessage(String message) async {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Notice"),
  //         content: Text(message),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _loginWithGoogle() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     // Trigger the Google sign-in flow
  //     final googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // The user canceled the sign-in
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     // Obtain the auth details from the request
  //     final googleAuth = await googleUser.authentication;
  //     final String? idToken = googleAuth.idToken;

  //     if (idToken == null) {
  //       _showMessage('Failed to obtain Google ID token');
  //       return;
  //     }

  //     // Call your backend API to verify the token and log in
  //     final response = await _googleIdVerifyAndLogin({'token': idToken});

  //     if (response != null && response['result'] == true) {
  //       // Save token locally (similar to localStorage in JS)
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('skilloptoken', response['token']);

  //       // Navigate to the homepage (adjust the route as needed)
  //       Navigator.pushReplacementNamed(context, '/homepage');
  //     } else {
  //       _showMessage(response?['message'] ?? 'Google Login Failed');
  //     }
  //   } catch (error) {
  //     _showMessage('Google Login Failed');
  //     debugPrint('Google login error: $error');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  /// Calls the backend API to verify the Google ID token and log in the user.
  // Future<Map<String, dynamic>?> _googleIdVerifyAndLogin(
  //     Map<String, String> data) async {
  //   // Replace with your actual API URL
  //   final url = Uri.parse('https://skillop.in/api/user/signin/google');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(data),
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body) as Map<String, dynamic>;
  //     } else {
  //       debugPrint('API error: ${response.statusCode}');
  //       return {
  //         'result': false,
  //         'message': 'Server error: ${response.statusCode}'
  //       };
  //     }
  //   } catch (error) {
  //     debugPrint('HTTP error: $error');
  //     return {'result': false, 'message': 'Network error'};
  //   }
  // }

  // Method to handle email/password login.
  Future<void> login(BuildContext context) async {
    final String email = usernameController.text.trim();
    final String password = passwdController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final responseData =
          await ApiService.userLogin(email: email, password: password);
      setState(() => _isLoading = false);

      if (responseData != null && responseData['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', responseData['token']);
        await prefs.setString(
            'userDetails', jsonEncode(responseData['result']));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showErrorDialog(responseData?['message'] ?? 'Login failed');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error during login: $error');
    }
  }

  // Method to show error dialogs.
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
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/signup', (Route<dynamic> route) => false),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Uncomment when Google sign in works
              // Row(
              //   children: [
              //     Expanded(
              //       child: Container(
              //         height: 4,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(4),
              //           color: const Color.fromRGBO(167, 166, 166, 1),
              //         ),
              //       ),
              //     ),
              //     const Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 8.0),
              //       child: Text(
              //         "OR",
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Container(
              //         height: 4,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(4),
              //           color: const Color.fromRGBO(167, 166, 166, 1),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 10),
              // Center(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 50),
              //     // When pressed, this button triggers Google login.
              //     child: GoogleLoginButton(onPressed: _loginWithGoogle),
              // ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
