import 'package:flutter/material.dart';
import 'package:moofli_app/components/gradient_button.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_upload_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_services.dart';

class SetupProfileSkills extends StatefulWidget {
  const SetupProfileSkills({super.key});

  @override
  State<SetupProfileSkills> createState() => _SetupProfileSkillsState();
}

class _SetupProfileSkillsState extends State<SetupProfileSkills> {
  double progressPercentage = 0.6;
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

  // Holds selected skills and their associated border colors.
  Map<String, Color> selected = {};
  List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
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

    // Use updateMultipleProfileFields to update skills.
    Map<String, dynamic> result = await ApiService.updateMultipleProfileFields({
      'skills': selectedSkills,
    });

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetupProfileUploadPhoto(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update skills")));
    }
  }

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
                          int colorIndex = selected.length % colors.length;
                          // Automatically select the newly added skill.
                          selected[newSkill] = colors[colorIndex];
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
      // Place navigation buttons in bottomNavigationBar.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: NavButtons(
          prev: '/setup_profile_professional_info',
          next: saveSkillDetails,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const SizedBox(height: 20),
            ProgressBar(progress: progressPercentage),
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
                    // Use a tinted background if selected; otherwise white.
                    backgroundColor: isSkillSelected
                        ? selected[skill]!.withOpacity(0.2)
                        : Colors.white,
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
            // Removed NavButtons from the ListView since they are now in bottomNavigationBar.
          ],
        ),
      ),
    );
  }
}
