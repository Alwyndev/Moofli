import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfile1 extends StatefulWidget {
  const SetupProfile1({super.key});

  @override
  State<SetupProfile1> createState() => _SetupProfile1State();
}

class _SetupProfile1State extends State<SetupProfile1> {
  Map<String, dynamic>? userData;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userDetails');
    String? token = prefs.getString('token');

    if (userDataJson != null) {
      setState(() {
        userData = json.decode(userDataJson);
        userData?['token'] = token;
      });

      await _fetchProfile(token);
    } else {
      print('User data not found in SharedPreferences');
    }
  }

  Future<void> _fetchProfile(String? token) async {
    if (token == null) {
      print("Token is null");
      return;
    }
    print(token);
    try {
      final response = await http.put(
        Uri.parse('https://skillop-back.onrender.com/api/user/update/profile'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  List<bool> isSelected = [true, false, false];
  late String gender;
  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 20),

            // Subtitle
            Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 2),

            // Title
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 8),

            // Decorative Line
            Row(
              children: [
                // Filled Progress
                Expanded(
                  flex: (0.2 * 100 ~/ 5), // First page, 0/6 progress
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
                  flex: (4 * 100 ~/ 5), // Remaining 5/6
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

            SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'You are ', // Normal text
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 109, 108, 108),
                    fontWeight: FontWeight.normal,
                  ),
                  children: [
                    TextSpan(
                      text: '0%', // Bold percentage
                      style: TextStyle(
                        color: const Color.fromARGB(255, 90, 90, 90),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' there', // Normal text after percentage
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            SizedBox(height: 10),
            TextField(
              controller: dobController,
              decoration: InputDecoration(
                hintText: 'dd-mm-yyyy',
                hintStyle: TextStyle(
                  fontSize: 20,
                ),
                labelText: 'DOB',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9\-]')), // Allows only numbers and hyphens
                LengthLimitingTextInputFormatter(
                    10), // Limits input to 10 characters
                TextInputFormatter.withFunction((oldValue, newValue) {
                  // Automatically formats the input as dd-mm-yyyy
                  final text = newValue.text;
                  if (text.length > 10) return oldValue;

                  String formatted = text;
                  if (text.length > 2 && !text.contains('-')) {
                    formatted = '${text.substring(0, 2)}-${text.substring(2)}';
                  }
                  if (text.length > 5 && text.split('-').length == 2) {
                    formatted =
                        '${formatted.substring(0, 5)}-${text.substring(5)}';
                  }
                  return TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gender',
                style: TextStyle(fontSize: 20),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                // Male Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 0); // Select Male
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[0]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width:
                            isSelected[0] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Male',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

                // Female Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 1); // Select Female
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[1]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width:
                            isSelected[1] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Female',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

                // Rather Not Say Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 2); // Select Rather Not Say
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[2]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width:
                            isSelected[2] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Rather Not Say',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            NavButtons(prev: '/signup', next: '/setup_profile_contact_info'),
          ],
        ),
      ),
    );
  }
}
