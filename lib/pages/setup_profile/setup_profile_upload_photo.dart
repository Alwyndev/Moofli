import 'dart:io';
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
      // Removed the immediate upload.
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

  /// Uploads the selected cover photo to the backend as multipart form data.
  /// Returns true if the upload is successful.
  Future<bool> uploadCoverPhoto() async {
    if (coverPhoto == null) return false;

    final uri =
        Uri.parse('http://93.127.172.217:2024/api/user/add/boackgroundPic');
    final request = http.MultipartRequest('POST', uri);

    // Attach the image file under the key "image"
    request.files.add(
      await http.MultipartFile.fromPath('image', coverPhoto!.path),
    );

    // Optionally include an authorization header if needed.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      request.headers['Authorization'] = token;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print("Cover photo uploaded successfully.");
      return true;
    } else {
      print("Cover photo upload failed with status: ${response.statusCode}");
      return false;
    }
  }

  /// Called when the Next button is pressed.
  /// This method first uploads the cover photo, then saves local paths and navigates to the next screen.
  Future<void> savePhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (profilePhoto != null) {
      await prefs.setString('profilePic', profilePhoto!.path);
    }
    if (coverPhoto != null) {
      bool uploadSuccess = await uploadCoverPhoto();
      if (uploadSuccess) {
        await prefs.setString('coverPic', coverPhoto!.path);
      } else {
        // Show an error message if the upload fails.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cover photo upload failed.")),
        );
        return; // Optionally halt navigation if upload fails.
      }
    }
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
              text: const TextSpan(
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
          NavButtons(prev: '/setup_profile_skills', next: savePhotos)
        ],
      ),
    );
  }
}
