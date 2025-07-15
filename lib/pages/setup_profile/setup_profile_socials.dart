import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_services.dart';

class SetupProfileSocials extends StatefulWidget {
  const SetupProfileSocials({super.key});

  @override
  State<SetupProfileSocials> createState() => _SetupProfileSocialsState();
}

class _SetupProfileSocialsState extends State<SetupProfileSocials> {
  double progressPercentage = 0.99;
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  Future<void> saveSocials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    bool result = false;
    if (token != null) {
      result = await ApiService.updateMultipleProfileFields(
        token,
        {
          'linkedIn': linkedInController.text,
          'upi': upiController.text,
        },
      );
    }
    if (result) {
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
            ProgressBar(progress: progressPercentage),
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: NavButtons(
          prev: '/setup_profile_photo',
          next: saveSocials,
        ),
      ),
    );
  }
}
