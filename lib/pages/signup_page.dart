import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moofli_app/google_login_button.dart';
import 'package:moofli_app/gradient_button.dart';

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
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo

            SizedBox(height: 20),

            // Title
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
            SizedBox(height: 20),

            // Input Field
            TextField(
              controller: fNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: lNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwdController,
              obscureText: status1, // Controls whether the text is obscured
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      status1 = !status1; // Toggle the visibility status
                    });
                  },
                  icon: Icon(
                    status1
                        ? Icons.visibility_off
                        : Icons.visibility, // Change icon dynamically
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              controller: rePasswdController,
              obscureText: status2, // Controls whether the text is obscured
              decoration: InputDecoration(
                labelText: 'Re-enter Password',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      status2 = !status2; // Toggle the visibility status
                    });
                  },
                  icon: Icon(
                    status2
                        ? Icons.visibility_off
                        : Icons.visibility, // Change icon dynamically
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            // To track if "Remember me" is checked
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Terms and Privacy Policy Checkbox with hyperlinks
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
                                color: Colors.blue, // Link color
                                decoration: TextDecoration
                                    .underline, // Underline the text
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Add your link opening functionality here
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
                                color: Colors.blue, // Link color
                                decoration: TextDecoration
                                    .underline, // Underline the text
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Add your link opening functionality here
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

                // Remember Me Checkbox
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

            // SizedBox(height: 2),
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
                      // Add your functionality
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

            // SizedBox(height: 10),
            // Gradient Button
            GradientButton(
              text: 'Setup Your Profile',
              onPressed: () {
                if (!termsAccepted) {
                  // Show an alert dialog if Terms and Privacy Policy are not accepted
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Terms and Privacy Policy'),
                        content: Text(
                            'Please accept the Terms of Use and Privacy Policy to continue.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                Navigator.pushNamed(context, '/setup_profile_1');
              },
              border: 20,
              padding: 12,
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
