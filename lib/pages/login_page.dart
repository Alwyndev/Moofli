import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moofli_app/google_login_button.dart';
import 'package:moofli_app/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance

  bool status = true;

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 32,
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
                    Colors.blue
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: status,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      status = !status;
                    });
                  },
                  icon: Icon(
                    status ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            GradientButton(
              text: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              border: 20,
              padding: 16,
            ),
            SizedBox(height: 10),
            Center(child: Text('Not Registered Yet?')),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: GoogleLoginButton(
                  onPressed: _handleGoogleLogin, // Pass the callback function
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
