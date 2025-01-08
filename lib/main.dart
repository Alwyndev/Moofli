// File: main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/signup_page.dart';
import 'pages/setup_profile/setup_profile_1.dart';
import 'pages/setup_profile/setup_profile_contact_info.dart';
import 'pages/setup_profile/setup_profile_profesional_info.dart';
import 'pages/setup_profile/setup_profile_skills.dart';
import 'pages/setup_profile/setup_profile_socials.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/setup_profile_1': (context) => const SetupProfile1(),
        '/setup_profile_contact_info': (context) =>
            const SetupProfileContactInfo(),
        '/setup_profile_professional_info': (context) =>
            const SetupProfileProfesionalInfo(),
        '/setup_profile_skills': (context) => const SetupProfileSkills(),
        '/setup_profile_socials': (context) => const SetupProfileSocials(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
    );
  }
}

// Additional files will follow the same pattern with appropriate updates for navigation.
