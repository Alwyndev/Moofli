import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfileContactInfo extends StatefulWidget {
  const SetupProfileContactInfo({super.key});

  @override
  State<SetupProfileContactInfo> createState() =>
      _SetupProfileContactInfoState();
}

class _SetupProfileContactInfoState extends State<SetupProfileContactInfo> {
  double progressPercentage = 0.2;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> saveContactInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phoneController.text);
    // await prefs.setString('email', emailController.text); // Uncomment if needed

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressBar(progress: progressPercentage),
            const SizedBox(height: 20),
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Secondary Email',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            NavButtons(prev: '/setup_profile_1', next: saveContactInfo),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
