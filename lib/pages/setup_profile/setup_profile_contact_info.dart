import 'package:flutter/material.dart';

class SetupProfileContactInfo extends StatefulWidget {
  const SetupProfileContactInfo({super.key});

  @override
  State<SetupProfileContactInfo> createState() =>
      _SetupProfileContactInfoState();
}

class _SetupProfileContactInfoState extends State<SetupProfileContactInfo> {
  // TextEditingControllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

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
            SizedBox(height: 100),

            // Subtitle
            Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 2),

            // Title
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 8),

            // Decorative Line
            Row(
              children: [
                // Filled Progress
                Expanded(
                  flex: (1 * 100 ~/ 5), // 2/6 progress
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Remaining Progress
                Expanded(
                  flex: (4 * 100 ~/ 5), // Remaining 4/6
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(224, 217, 217, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'You are ', // Normal text
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 109, 108, 108),
                    fontWeight: FontWeight.normal,
                  ),
                  children: [
                    TextSpan(
                      text: '20%', // Bold percentage
                      style: TextStyle(
                        color: const Color.fromARGB(255, 90, 90, 90),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' there', // Normal text after percentage
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Phone Number
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                prefix: RichText(
                  text: TextSpan(
                    text: '   +91   ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '|    ',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 87, 87, 87),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'something@example.com',
                hintStyle: TextStyle(
                  fontSize: 20,
                ),
                labelText: 'Email',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Spreads the buttons apart
                  children: [
                    // Back Button (Circular)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/setup_profile_1');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Icon(Icons.arrow_back,
                            size: 24, color: Colors.black),
                      ),
                    ),

                    // Next Button (Rounded Rectangle)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/setup_profile_skills');
                      }, // Add your onTap logic here
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "NEXT",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8), // Space between text and icon
                            Icon(Icons.arrow_forward,
                                size: 24, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
