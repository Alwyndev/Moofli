import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfileContactInfo extends StatefulWidget {
  const SetupProfileContactInfo({super.key});

  @override
  State<SetupProfileContactInfo> createState() =>
      _SetupProfileContactInfoState();
}

class _SetupProfileContactInfoState extends State<SetupProfileContactInfo> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  String? emailError;

  Future<void> saveContactInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile', phoneController.text);
    await prefs.setString('city', cityController.text);

    if (!mounted) return;

    Navigator.pushNamed(context, '/setup_profile_professional_info');
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
            const SizedBox(height: 20),
            const Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: (1 * 100 ~/ 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
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
                Expanded(
                  flex: (4 * 100 ~/ 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(224, 217, 217, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: const TextSpan(
                  text: 'You are ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 109, 108, 108),
                  ),
                  children: [
                    TextSpan(
                      text: '20%',
                      style: TextStyle(
                        color: Color.fromARGB(255, 90, 90, 90),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' there',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                prefix: RichText(
                  text: const TextSpan(
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
                          color: Color.fromARGB(255, 87, 87, 87),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                labelText: 'Phone Number',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'something@example.com',
                hintStyle: const TextStyle(fontSize: 20),
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                errorText: emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
              ],
              onChanged: (value) {
                setState(() {
                  if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    emailError = 'Invalid email format';
                  } else {
                    emailError = null;
                  }
                });
              },
            ),
            if (emailError != null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  'Invalid email format',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NavButtons(prev: '/setup_profile_1', next: saveContactInfo),
          ],
        ),
      ),
    );
  }
}
