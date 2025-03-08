import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SetupProfileUploadPhoto extends StatefulWidget {
  const SetupProfileUploadPhoto({super.key});

  @override
  State<SetupProfileUploadPhoto> createState() =>
      _SetupProfileUploadPhotoState();
}

class _SetupProfileUploadPhotoState extends State<SetupProfileUploadPhoto> {
  XFile? coverPhoto;
  XFile? profilePhoto;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickCoverPhoto() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        coverPhoto = pickedImage;
      });
    }
  }

  Future<void> pickProfilePhoto() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        profilePhoto = pickedImage;
      });
    }
  }

  /// Uploads both the cover and profile photos to the backend.
  /// Returns true only if both uploads are successful.
  Future<bool> uploadPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    bool coverUploadSuccess = false;
    bool profileUploadSuccess = false;

    // --- Upload Cover Photo ---
    if (coverPhoto != null) {
      final uriCoverPhoto =
          Uri.parse('https://skillop.in/api/user/add/boackgroundPic');
      final coverRequest = http.MultipartRequest('POST', uriCoverPhoto);

      // Attach the cover photo with key "profileBackgroundPic"
      coverRequest.files.add(
        await http.MultipartFile.fromPath(
            'profileBackgroundPic', coverPhoto!.path),
      );

      if (token != null) {
        coverRequest.headers['Authorization'] = token;
      }

      final coverResponse = await coverRequest.send();
      coverUploadSuccess = coverResponse.statusCode == 200;
      if (kDebugMode) {
        print(coverUploadSuccess
            ? "Cover photo uploaded successfully."
            : "Cover photo upload failed with status: ${coverResponse.statusCode}");
      }
    }

    // --- Upload Profile Photo ---
    if (profilePhoto != null) {
      final uriProfilePic =
          Uri.parse('https://skillop.in/api/user/update/profile');
      final profileRequest = http.MultipartRequest('PUT', uriProfilePic);

      // Attach the profile photo with key "profilePic"
      profileRequest.files.add(
        await http.MultipartFile.fromPath('profilePic', profilePhoto!.path),
      );

      if (token != null) {
        profileRequest.headers['Authorization'] = token;
      }

      final profileResponse = await profileRequest.send();
      profileUploadSuccess = profileResponse.statusCode == 200;
      if (kDebugMode) {
        print(profileUploadSuccess
            ? "Profile photo uploaded successfully."
            : "Profile photo upload failed with status: ${profileResponse.statusCode}");
      }
    }

    return coverUploadSuccess && profileUploadSuccess;
  }

  /// Called when the Next button is pressed.
  /// First checks that both photos have been selected,
  /// then attempts to upload them, saves the local paths if successful,
  /// and navigates to the next screen.
  Future<void> savePhotos() async {
    // Uncomment these if both the photos are to be compulsarily uploaded.
    // if (coverPhoto == null || profilePhoto == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please select both photos.")),
    //   );
    //   return;
    // }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool uploadSuccess = await uploadPhotos();
    if (!uploadSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo upload failed.")),
      );
      return;
    }

    // Save the local file paths if needed.
    await prefs.setString('profilePic', profilePhoto!.path);
    await prefs.setString('coverPic', coverPhoto!.path);

    Navigator.pushNamed(context, '/setup_profile_socials');
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: (4 * 100 ~/ 5),
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
                flex: (1 * 100 ~/ 5),
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
          const SizedBox(height: 10),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'You are ',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 109, 108, 108),
                ),
                children: [
                  TextSpan(
                    text: '80%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' there',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cover Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: pickCoverPhoto,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: Colors.grey[200],
              ),
              child: coverPhoto == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 32, color: Colors.black),
                          Text('UPLOAD'),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(coverPhoto!.path),
                        fit: BoxFit.cover,
                        height: 150,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: pickProfilePhoto,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Colors.grey[200],
                ),
                child: profilePhoto == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 48, color: Colors.black),
                          Text('UPLOAD'),
                        ],
                      )
                    : ClipOval(
                        child: Image.file(
                          File(profilePhoto!.path),
                          fit: BoxFit.cover,
                          height: 120,
                          width: 120,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          NavButtons(prev: '/setup_profile_skills', next: savePhotos),
        ],
      ),
    );
  }
}
