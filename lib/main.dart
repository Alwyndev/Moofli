import 'package:flutter/material.dart';
import 'package:moofli_app/pages/profile_page.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_1.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_contact_info.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_profesional_info.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_skills.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_socials.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_upload_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/settings_page.dart';
import 'pages/diary_page_new.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await getLoginStatus();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

// Function to check login status from SharedPreferences
Future<bool> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => const HomePage(),
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
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => ProfilePage(),
      },
      title: 'Moofli App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
    );
  }
}
