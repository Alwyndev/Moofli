import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moofli_app/components/google_login_button.dart';
import 'package:moofli_app/components/gradient_button.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool status1 = true;
  bool status2 = true;
  bool termsAccepted =
      false; // To track if Terms and Privacy Policy are accepted
  bool rememberMe = false;

  Future<void> _handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print("Google User: ${googleUser.displayName}");
        print("Email: ${googleUser.email}");
        print("Photo URL: ${googleUser.photoUrl}");
        // Additional actions can be performed here
      } else {
        print("User canceled the sign-in process.");
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
  }

  // Text Editing Controllers
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();
  final TextEditingController rePasswdController = TextEditingController();

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _registerUser() async {
    if (!termsAccepted) {
      _showDialog('Terms and Privacy Policy',
          'Please accept the Terms of Use and Privacy Policy to continue.');
      return;
    }

    if (fNameController.text.isEmpty || lNameController.text.isEmpty) {
      _showDialog('Error', 'First and Last name cannot be empty!');
      return;
    }

    if (emailController.text.isEmpty ||
        !emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      _showDialog('Error', 'Please fill in a valid email to continue!');
      return;
    }

    if (passwdController.text != rePasswdController.text) {
      _showDialog('Error', 'Passwords do not match!');
      return;
    }

    if (passwdController.text.length < 6) {
      _showDialog('Error', 'Password must be at least 6 characters long!');
      return;
    }

    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(emailController.text)) {
      _showDialog('Error', 'Please enter a valid email address!');
      return;
    }

    final url = Uri.parse('http://93.127.172.217:2004/api/user/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwdController.text,
          "firstname": fNameController.text,
          "lastname": lNameController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar(responseData['message'], Colors.green);
        Navigator.pushNamed(context, '/setup_profile_1');
      } else {
        _showDialog('Error', '${responseData['message']}');
      }
    } catch (error) {
      _showDialog('Network error', 'Please try again later');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 10),
            Text(
              'SIGN UP',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 8,
              width: 50,
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
              controller: fNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: lNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwdController,
              obscureText: status1,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      status1 = !status1;
                    });
                  },
                  icon: Icon(status1 ? Icons.visibility_off : Icons.visibility),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: rePasswdController,
              obscureText: status2,
              decoration: InputDecoration(
                labelText: 'Re-enter Password',
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      status2 = !status2;
                    });
                  },
                  icon: Icon(status2 ? Icons.visibility_off : Icons.visibility),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          termsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'By signing up, you are creating a SKILLOP account, and you agree to ',
                              style: TextStyle(fontSize: 12),
                            ),
                            TextSpan(
                              text: 'SKILLOP\'s Terms of Use',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Terms of Use clicked");
                                },
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(fontSize: 12),
                            ),
                            TextSpan(
                              text: 'Privacy Policy.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Privacy Policy clicked");
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Remember me as a Member of SKILLOP Community',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Already a member?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: Text(
                      'LOG IN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GradientButton(
              text: 'Setup Your Profile',
              onPressed: _registerUser,
              border: 20,
              padding: 12,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(4)),
                      color: Color.fromRGBO(167, 166, 166, 1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      color: Color.fromRGBO(87, 87, 87, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(4)),
                      color: Color.fromRGBO(167, 166, 166, 1),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: GoogleLoginButton(
                  onPressed: _handleGoogleLogin,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
