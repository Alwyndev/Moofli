import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:moofli_app/api/api_service.dart';
import 'package:moofli_app/components/gradient_button.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfileSkills extends StatefulWidget {
  const SetupProfileSkills({super.key});

  @override
  State<SetupProfileSkills> createState() => _SetupProfileSkillsState();
}

class _SetupProfileSkillsState extends State<SetupProfileSkills> {
  List<String> skills = [
    "Web Development",
    "UI/UX",
    "Data Structures & Algorithms",
    "Technology",
    "AI/ML",
    "Data Analysis",
    "Leadership",
    "Product Engineering"
  ];

  void _showAddSkillModal(BuildContext context) {
    TextEditingController skillController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Skill/Interest"),
          content: TextField(
            controller: skillController,
            decoration: InputDecoration(
              hintText: 'Add a Skill or Interest',
              hintStyle: const TextStyle(fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Add',
                    onPressed: () {
                      String newSkill = skillController.text.trim();
                      if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
                        setState(() {
                          skills.add(newSkill);
                        });
                      }
                      Navigator.pop(context);
                    },
                    border: 14,
                    padding: 4,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    border: 14,
                    padding: 4,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Map<String, Color> selected = {};
  List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.orange,
    Colors.blue,
    Colors.green
  ];

  void _toggleSkillSelection(String skill) {
    setState(() {
      if (selected.containsKey(skill)) {
        selected.remove(skill);
      } else {
        int colorIndex = selected.length % colors.length;
        selected[skill] = colors[colorIndex];
      }
    });
  }

  List<String> get selectedSkills => selected.keys.toList();

  Future<void> saveSkillDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedSkills', selectedSkills);

    // Convert skills list to JSON (or a comma-separated string based on your API design)
    String skillsJson = jsonEncode(selectedSkills);

    bool success = await ApiService.updateProfileField('skills', skillsJson);

    if (success) {
      Navigator.pushNamed(context, '/setup_profile_photo');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update skills")));
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
                  flex: (2 * 100 ~/ 5),
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
                  flex: (3 * 100 ~/ 5),
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
                      text: '60%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' there',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Skill / Internship',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: skills.map((skill) {
                bool isSkillSelected = selected.containsKey(skill);
                Color borderColor =
                    isSkillSelected ? selected[skill]! : Colors.grey;
                return GestureDetector(
                  onTap: () => _toggleSkillSelection(skill),
                  child: Chip(
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: borderColor, width: 3.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        skills.remove(skill);
                        selected.remove(skill);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Add a Skill/Interest',
              onPressed: () {
                _showAddSkillModal(context);
              },
              border: 20,
              padding: 4,
            ),
            const SizedBox(height: 20),
            NavButtons(
                prev: '/setup_profile_professional_info',
                next: saveSkillDetails)
          ],
        ),
      ),
    );
  }
}
