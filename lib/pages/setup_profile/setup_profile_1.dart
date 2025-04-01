import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfile1 extends StatefulWidget {
  const SetupProfile1({super.key});

  @override
  State<SetupProfile1> createState() => _SetupProfile1State();
}

class _SetupProfile1State extends State<SetupProfile1> {
  List<bool> isSelected = [true, false, false];
  String gender = "Male";
  double progressPercentage = 0.01;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Future<void> savePersonalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', nameController.text);
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  ProgressBar(progress: progressPercentage),
                  const SizedBox(height: 20),
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(
                      hintText: 'dd-mm-yyyy',
                      hintStyle: const TextStyle(fontSize: 20),
                      labelText: 'Date of Birth',
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
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
                      genderButton(
                          'Male', 0, Colors.blue.shade100, Colors.blue),
                      const SizedBox(width: 16),
                      genderButton(
                          'Female', 1, Colors.pink.shade100, Colors.pink),
                      const SizedBox(width: 16),
                      genderButton('Rather Not Say', 2, Colors.grey.shade300,
                          Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            NavButtons(prev: '/signup', next: savePersonalInfo),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget genderButton(
      String text, int index, Color fillColor, Color borderColor) {
    return InkWell(
      onTap: () {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = (i == index);
          }
          gender = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected[index] ? fillColor : Colors.transparent,
          border: Border.all(
            color: isSelected[index] ? borderColor : Colors.grey,
            width: isSelected[index] ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
