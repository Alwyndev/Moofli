import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfile1 extends StatefulWidget {
  const SetupProfile1({super.key});

  @override
  State<SetupProfile1> createState() => _SetupProfile1State();
}

class _SetupProfile1State extends State<SetupProfile1> {
  List<bool> isSelected = [true, false, false];
  // Initialize with a default value.
  String gender = "Male";

  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Future<void> savePersonalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('gender', gender);

    if (!mounted) return;

    Navigator.pushNamed(context, '/setup_profile_contact_info');
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          scrollDirection: Axis.vertical,
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
            Row(
              children: [
                Expanded(
                  flex: (0.2 * 100 ~/ 5), // First page progress
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
                  flex: (4 * 100 ~/ 5), // Remaining progress
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
            const SizedBox(height: 20),
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
                      text: '0%',
                      style: TextStyle(
                        color: Color.fromARGB(255, 90, 90, 90),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' there',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dobController,
              decoration: InputDecoration(
                hintText: 'dd-mm-yyyy',
                hintStyle: const TextStyle(fontSize: 20),
                labelText: 'DOB',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                LengthLimitingTextInputFormatter(10),
                TextInputFormatter.withFunction((oldValue, newValue) {
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
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Gender',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Male Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 0);
                      }
                      gender = "Male";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[0] ? Colors.black : Colors.grey,
                        width: isSelected[0] ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent,
                    ),
                    child: const Text(
                      'Male',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Female Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 1);
                      }
                      gender = "Female";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[1] ? Colors.black : Colors.grey,
                        width: isSelected[1] ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent,
                    ),
                    child: const Text(
                      'Female',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Rather Not Say Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 2);
                      }
                      gender = "Rather Not Say";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[2] ? Colors.black : Colors.grey,
                        width: isSelected[2] ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent,
                    ),
                    child: const Text(
                      'Rather Not Say',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            NavButtons(prev: '/signup', next: savePersonalInfo),
          ],
        ),
      ),
    );
  }
}
