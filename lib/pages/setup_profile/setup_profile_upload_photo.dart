import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../components/gradient_button.dart';

class SetupProfileUploadPhoto extends StatefulWidget {
  final bool showProgress;
  const SetupProfileUploadPhoto({super.key, this.showProgress = true});

  @override
  State<SetupProfileUploadPhoto> createState() =>
      _SetupProfileUploadPhotoState();
}

class _SetupProfileUploadPhotoState extends State<SetupProfileUploadPhoto> {
  bool isLoading = false;
  double progressPrecentage = 0.8;
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

  /// Uploads only the selected photos to the backend.
  /// For photos that are not selected, upload is skipped.
  /// Returns true if all attempted uploads succeed.
  Future<bool> uploadPhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    bool coverUploadSuccess = true;
    bool profileUploadSuccess = true;

    // --- Upload Cover Photo if selected ---
    if (coverPhoto != null) {
      final uriCoverPhoto =
          Uri.parse('https://skillop.in/api/user/add/boackgroundPic');
      final coverRequest = http.MultipartRequest('POST', uriCoverPhoto);
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

    // --- Upload Profile Photo if selected ---
    if (profilePhoto != null) {
      final uriProfilePic =
          Uri.parse('https://skillop.in/api/user/update/profile');
      final profileRequest = http.MultipartRequest('PUT', uriProfilePic);
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

  /// Called when the Next button is pressed (when showProgress is true).
  /// If no photo is selected, it navigates to the next page.
  /// Otherwise, it uploads only the selected photos before navigating.
  Future<void> savePhotos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    // If no photo is selected, skip uploading.
    if (coverPhoto == null && profilePhoto == null) {
      Navigator.pushNamed(context, '/setup_profile_socials');
      return;
    }

    bool uploadSuccess = await uploadPhotos();
    if (!uploadSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo upload failed.")),
      );
      return;
    }

    // Save the local file paths if the photos exist.
    if (profilePhoto != null) {
      await prefs.setString('profilePic', profilePhoto!.path);
    }
    if (coverPhoto != null) {
      await prefs.setString('coverPic', coverPhoto!.path);
    }

    setState(() {
      isLoading = false;
    });
    Navigator.pushNamed(context, '/setup_profile_socials');
  }

  /// Called when showProgress is false.
  /// Saves the changes and pops the page to reveal the caller.
  Future<void> saveAndPop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If no photo is selected, simply pop.
    if (coverPhoto == null && profilePhoto == null) {
      Navigator.pop(context);
      return;
    }

    bool uploadSuccess = await uploadPhotos();
    if (!uploadSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo upload failed.")),
      );
      return;
    }

    if (profilePhoto != null) {
      await prefs.setString('profilePic', profilePhoto!.path);
    }
    if (coverPhoto != null) {
      await prefs.setString('coverPic', coverPhoto!.path);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Build the main content for the page.
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showProgress) ...[
          ProgressBar(progress: progressPrecentage),
          const SizedBox(height: 20),
        ],
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
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: widget.showProgress
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: NavButtons(
                prev: '/setup_profile_skills',
                next: savePhotos,
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                height: 50, // Set a fixed height for the button
                child: GradientButton(
                  onPressed: saveAndPop,
                  text: 'Save',
                  border: 16,
                  padding: 2,
                ),
              ),
            ),
      body: widget.showProgress
          ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [content],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: content,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
