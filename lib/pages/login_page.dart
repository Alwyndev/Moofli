import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moofli_app/components/google_login_button.dart';
import 'package:moofli_app/components/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Text Editing Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwdController = TextEditingController();

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
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Column(
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
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwdController,
                  obscureText: status,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
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
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/reset_password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 10),
                Row(
                  children: [
                    // Progress bar on the left
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
                    // "OR" text
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
                    // Progress bar on the right
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
                SizedBox(height: 10),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: GoogleLoginButton(
                      onPressed:
                          _handleGoogleLogin, // Pass the callback function
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
