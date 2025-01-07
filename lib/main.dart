import 'package:flutter/material.dart';
import 'package:moofli_app/home_page.dart';
import 'package:moofli_app/setup_profile_contact_info.dart';
import 'package:moofli_app/setup_profile_profesional_info.dart';
import 'package:moofli_app/setup_profile_skills.dart';
import 'package:moofli_app/setup_profile_socials.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
