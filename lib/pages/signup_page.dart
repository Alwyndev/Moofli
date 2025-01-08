import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moofli_app/gradient_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool status1 = true;
  bool status2 = true;
  bool termsAccepted =
      false; // To track if Terms and Privacy Policy are accepted
  bool rememberMe = false;
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
            SizedBox(height: 40),

            // Input Field
            TextField(
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
            const SizedBox(height: 10),
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
                              style: TextStyle(fontSize: 14),
                            ),
                            TextSpan(
                              text: 'SKILLOP\'s Terms of Use',
                              style: TextStyle(
                                fontSize: 14,
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
                              style: TextStyle(fontSize: 14),
                            ),
                            TextSpan(
                              text: 'Privacy Policy.',
                              style: TextStyle(
                                fontSize: 14,
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
                SizedBox(height: 10),

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
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10),
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

            SizedBox(height: 20),
            // Gradient Button
            GradientButton(
              text: 'Setup Your Profile',
              onPressed: () {
                // Add your functionality
                Navigator.pushNamed(context, '/setup_profile_1');
              },
              border: 20,
              padding: 16,
            ),

            SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Sign Up With Google Pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensures the button width matches its content
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png', // Replace with the path to your Google logo
                          height: 24.0,
                          width: 24.0,
                        ),
                        SizedBox(width: 12.0), // Space between logo and text
                        Text(
                          'Sign Up With Google',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
