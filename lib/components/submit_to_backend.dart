import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Submits user data (including socials) to the backend.
/// Returns true if the submission was successful (HTTP 200), false otherwise.
Future<bool> submitToBackend() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve all the necessary user data from SharedPreferences.
  Map<String, dynamic> userData = {
    // auth info
    "email": prefs.getString('email') ?? '',
    "password": prefs.getString('password') ?? '',
    "fname": prefs.getString('fname') ?? '',
    "lname": prefs.getString('lname') ?? '',
    // personal info
    "dob": prefs.getString('dob') ?? '',

    // contact info
    "phone": prefs.getString('mobile') ?? '',
    "city": prefs.getString('city') ?? '',

    // professional info
    "profession": prefs.getString('Profession') ?? '',
    "college": prefs.getString('College') ?? '',
    "degree": prefs.getString('Degree') ?? '',
    "field": prefs.getString('fieldOfStudy') ?? '',
    "colStart": prefs.getString('startCollege') ?? '',
    "colEnd": prefs.getString('endCollege') ?? '',

    // working professional
    "company": prefs.getString('company') ?? '',
    "designation": prefs.getString('JobTitle') ?? '',
    "jobType": prefs.getString('Description') ?? '',
    "jobStart": prefs.getString('startJob') ?? '',
    "jobEnd": prefs.getString('endJob') ?? '',

    // skills
    "skills": prefs.getStringList('skills') ?? [],

    // photos
    "profilePhoto": prefs.getString('profilePic') ?? '',
    "coverPhoto": prefs.getString('coverPic') ?? '',

    // socials
    "linkedIn": prefs.getString('linkedIn') ?? '',
    "upi": prefs.getString('upi') ?? '',
  };

  final response = await http.post(
    Uri.parse('http://93.127.172.217:2024/api/user/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(userData),
  );

  if (response.statusCode == 200) {
    // Optionally, process the response data as needed.
    // Here we save the entire response (expected to be user details) in SharedPreferences.
    await prefs.setString('userDetails', response.body);
    return true;
  } else {
    return false;
  }
}
