import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Editable fields
  String name = "France Leaphart 🌟";
  String bio = "B.Tech CSE@DTU | DSA |\nWeb Development";
  String linkedin = "www.linkedin.com/in/france-leaphart";
  String about = "Lorem ipsum dolor sit amet...";
  String pastExperience = "Lorem ipsum dolor sit amet...";
  String futurePlans = "Lorem ipsum dolor sit amet...";

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _pastExperienceController =
      TextEditingController();
  final TextEditingController _futurePlansController = TextEditingController();

  // Lists for dynamic sections
  List<Map<String, String>> experienceItems = [
    {
      "title": "Software Development Intern",
      "company": "Flipkart",
      "duration": "May 23 - Nov 23"
    },
    {
      "title": "DevFest Organizing Team Member",
      "company": "Google For Developers",
      "duration": "Oct 23 - Nov 23"
    },
  ];

  List<String> skills = [
    "Web Development",
    "Technology",
    "DSA",
    "UI/UX Design"
  ];

  // Flag to toggle edit mode
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _nameController.text = name;
    _bioController.text = bio;
    _linkedinController.text = linkedin;
    _aboutController.text = about;
    _pastExperienceController.text = pastExperience;
    _futurePlansController.text = futurePlans;
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _aboutController.dispose();
    _pastExperienceController.dispose();
    _futurePlansController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveChanges() {
    setState(() {
      name = _nameController.text;
      bio = _bioController.text;
      linkedin = _linkedinController.text;
      about = _aboutController.text;
      pastExperience = _pastExperienceController.text;
      futurePlans = _futurePlansController.text;
      isEditing = false;
    });
  }

  void _addExperience() async {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final durationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Experience"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(hintText: "Company"),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(hintText: "Duration"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  experienceItems.add({
                    "title": titleController.text,
                    "company": companyController.text,
                    "duration": durationController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addSkill() async {
    final skillController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Skill"),
          content: TextField(
            controller: skillController,
            decoration: const InputDecoration(hintText: "Skill Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  skills.add(skillController.text);
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteExperience(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Experience"),
          content:
              const Text("Are you sure you want to delete this experience?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        experienceItems.removeAt(index);
      });
    }
  }

  void _confirmDeleteSkill(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Skill"),
          content: const Text("Are you sure you want to delete this skill?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        skills.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/main_logo.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          isEditing
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _bioController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your bio",
                                    ),
                                  ),
                                )
                              : Text(
                                  bio,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          if (isEditing) {
                            _saveChanges();
                          } else {
                            _toggleEditMode();
                          }
                        },
                        child: Text(
                          isEditing ? "Save" : "Edit Profile",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.link),
                      const SizedBox(width: 8),
                      isEditing
                          ? Expanded(
                              child: TextField(
                                controller: _linkedinController,
                                decoration: const InputDecoration(
                                  hintText: "Enter LinkedIn URL",
                                ),
                              ),
                            )
                          : Text(
                              linkedin,
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildSection("ABOUT", about, _aboutController, isEditing),
                  buildSection("Past Experience", pastExperience,
                      _pastExperienceController, isEditing),
                  buildSection("Future Plans", futurePlans,
                      _futurePlansController, isEditing),
                  buildExperienceSection(),
                  buildSkillsSection(),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/home");
              },
              child: const Icon(Icons.home, color: Colors.black, size: 40),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, String content,
      TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Enter $title",
                  ),
                )
              : Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildExperienceSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "EXPERIENCE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isEditing)
                IconButton(
                  onPressed: _addExperience,
                  icon: const Icon(Icons.add, color: Colors.blue),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: experienceItems
                .asMap()
                .entries
                .map((entry) => buildExperienceItem(
                      entry.value["title"]!,
                      entry.value["company"]!,
                      entry.value["duration"]!,
                      entry.key,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildExperienceItem(
      String title, String company, String duration, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(company,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(duration,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteExperience(index),
            ),
        ],
      ),
    );
  }

  Widget buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "SKILLS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isEditing)
                IconButton(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add, color: Colors.blue),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: skills
                .map((skill) => buildSkillChip(
                      skill,
                      [
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                      ][skills.indexOf(skill) %
                          4], // Repeating pattern of 4 colors
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildSkillChip(String label, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.15),
      onDeleted:
          isEditing ? () => _confirmDeleteSkill(skills.indexOf(label)) : null,
      label: Text(label, style: const TextStyle(color: Colors.black)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: 2),
      ),
    );
  }
}
