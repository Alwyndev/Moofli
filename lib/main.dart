import 'package:flutter/material.dart';
// import 'package:moofli_app/reset_password_page.dart';
// import 'package:moofli_app/login_page.dart';
import 'package:moofli_app/setup_profile_1.dart';
import 'package:moofli_app/setup_profile_contact_info.dart';
// import 'package:moofli_app/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SetupProfileContactInfo(),
    );
  }
}
