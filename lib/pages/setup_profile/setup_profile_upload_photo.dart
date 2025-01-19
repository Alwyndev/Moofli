import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
              // Filled Progress
              Expanded(
                flex: (4 * 100 ~/ 5),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
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

              // Remaining Progress
              Expanded(
                flex: (1 * 100 ~/ 5), // Remaining 4/5
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(224, 217, 217, 1),
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
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: coverPhoto == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload, size: 32, color: Colors.black),
                          Text('UPLOAD'),
                        ],
                      ),
                    )
                  : Image.file(
                      File(coverPhoto!.path),
                      fit: BoxFit.cover,
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
          GestureDetector(
            onTap: pickProfilePhoto,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: profilePhoto == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload, size: 32, color: Colors.black),
                          Text('UPLOAD'),
                        ],
                      ),
                    )
                  : ClipOval(
                      child: Image.file(
                        File(profilePhoto!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/setup_profile_professional_info');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 24, color: Colors.black),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/setup_profile_socials');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "NEXT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 24, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}