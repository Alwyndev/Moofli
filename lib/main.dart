import 'package:flutter/material.dart';
import 'package:moofli_app/pages/diary_entry_page.dart';
import 'package:moofli_app/pages/diary_page_new.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_upload_photo.dart';
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
        '/diary_entry': (context) => const DiaryEntryPage(),
        '/dairy_entry_new': (context) => const DiaryPageNew(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/setup_profile_1': (context) => const SetupProfile1(),
        '/setup_profile_contact_info': (context) =>
            const SetupProfileContactInfo(),
        '/setup_profile_professional_info': (context) =>
            const SetupProfileProfesionalInfo(),
        '/setup_profile_skills': (context) => const SetupProfileSkills(),
        '/setup_profile_photo': (context) => const SetupProfileUploadPhoto(),
        '/setup_profile_socials': (context) => const SetupProfileSocials(),
      },
      title: 'Moofli App',
      theme: ThemeData(
        // brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
    );
  }
}
