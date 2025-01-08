import 'package:flutter/material.dart';
import 'package:moofli_app/gradient_button.dart';

// Assuming you have this custom widget implemented.

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

  // void _addSkill(String newSkill) {
  //   if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
  //     setState(() {
  //       skills.add(newSkill);
  //     });
  //   }
  // }

  void _showAddSkillModal(BuildContext context) {
    TextEditingController skillController =
        TextEditingController(); // Controller for the input field

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a Skill/Interest"),
          content: TextField(
            controller: skillController, // Attach the controller
            decoration: InputDecoration(
              hintText: 'Add a Skill or Interest',
              hintStyle: TextStyle(
                fontSize: 16,
              ),
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
                      String newSkill =
                          skillController.text.trim(); // Get the input value
                      if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
                        setState(() {
                          skills.add(newSkill); // Add the skill to the list
                        });
                      }
                      Navigator.pop(context); // Close the dialog
                    },
                    border: 14,
                    padding: 4,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GradientButton(
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
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

  Map<String, Color> selectedSkills =
      {}; // To track selected skills and their colors
  List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.orange,
    Colors.blue,
    Colors.green
  ];

  void _toggleSkillSelection(String skill) {
    setState(() {
      if (selectedSkills.containsKey(skill)) {
        // Deselect if already selected
        selectedSkills.remove(skill);
      } else {
        // Select and assign a color (cyclically)
        int colorIndex = selectedSkills.length % colors.length;
        selectedSkills[skill] = colors[colorIndex];
      }
    });
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
            SizedBox(height: 100),

            // Subtitle
            Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            // Title
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            // Decorative Line
            Row(
              children: [
                Container(
                  height: 8,
                  width: 125,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(4)),
                      color: Color.fromRGBO(224, 217, 217, 1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

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
                      text: '40%',
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
            SizedBox(height: 20),
            Text(
              'Skill / Internship',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: skills.map((skill) {
                bool isSelected = selectedSkills.containsKey(skill);
                Color borderColor =
                    isSelected ? selectedSkills[skill]! : Colors.grey;

                return GestureDetector(
                  onTap: () => _toggleSkillSelection(skill),
                  child: Chip(
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: borderColor,
                          width: 3.0), // Dynamic border color
                      borderRadius:
                          BorderRadius.circular(20), // Circular border
                    ),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        skills.remove(skill); // Enables skill deletion
                        selectedSkills
                            .remove(skill); // Also remove from selected map
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            GradientButton(
              text: 'Add a Skill/Interest',
              onPressed: () {
                _showAddSkillModal(context);
              },
              border: 20,
              padding: 4,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (Circular)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/setup_profile_contact_info',
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child:
                          Icon(Icons.arrow_back, size: 24, color: Colors.black),
                    ),
                  ),

                  // Next Button (Rounded Rectangle)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/setup_profile_professional_info',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "NEXT",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              size: 24, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
