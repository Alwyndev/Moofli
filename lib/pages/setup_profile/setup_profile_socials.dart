import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_services.dart';

class SetupProfileSocials extends StatefulWidget {
  const SetupProfileSocials({super.key});

  @override
  State<SetupProfileSocials> createState() => _SetupProfileSocialsState();
}

class _SetupProfileSocialsState extends State<SetupProfileSocials> {
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  Future<void> saveSocials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('linkedIn', linkedInController.text);
    await prefs.setString('upi', upiController.text);

    Map<String, dynamic> result = await ApiService.updateMultipleProfileFields({
      'linkedIn': linkedInController.text,
      'upi': upiController.text,
    });

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update socials")));
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
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                      text: '99%',
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
              'Social Handles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: linkedInController,
              decoration: InputDecoration(
                labelText: 'LinkedIn Profile',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            NavButtons(prev: '/setup_profile_photo', next: saveSocials)
          ],
        ),
      ),
    );
  }
}
