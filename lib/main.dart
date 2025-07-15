import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'pages/account_info_page.dart';
import 'pages/diary_page_new.dart';

// Function to check login status from SharedPreferences
Future<bool> getLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await getLoginStatus();
  runApp(ProviderScope(child: MyApp(isLoggedIn: isLoggedIn)));
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
        '/diary_entry_new': (context) => DiaryPageNew(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/setup_profile_1': (context) => const SetupProfile1(),
        '/setup_profile_contact_info': (context) =>
            const SetupProfileContactInfo(),
        '/setup_profile_professional_info': (context) =>
            const SetupProfileProfesionalInfo(),
        '/setup_profile_skills': (context) => const SetupProfileSkills(),
        '/setup_profile_photo': (context) => const SetupProfileUploadPhoto(),
        '/setup_profile_socials': (context) => const SetupProfileSocials(),
        '/account_info': (context) => AccountInfoPage(),
        '/profile': (context) => ProfilePage(),
      },
      title: 'Moofli Diary',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Product Sans',
        useMaterial3: true,
      ),
    );
  }
}
