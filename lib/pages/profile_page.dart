import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String bio = "";
  String linkedin = "";
  String about = "";
  String pastExperience = "";
  String futurePlans = "";
  String profilepic = "";
  List<String> skills = [];
  List<Map<String, String>> experienceItems = [];
  String bgPic = "";
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
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2004/api/user/profile/me'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            name = responseData['result']['firstname'] ?? "";
            bio = responseData['result']['about'] ?? "";
            linkedin = responseData['result']['linkedinId'] ?? "";
            about = responseData['result']['about'] ?? "";
            pastExperience = responseData['result']['pastExp'] ?? "";
            futurePlans = responseData['result']['futurePlans'] ?? "";
            profilepic = responseData['result']['profilePicUrl'] ?? "";
            skills = List<String>.from(responseData['result']['skills'] ?? []);
            bgPic = responseData['result']['bgPicUrl'] ?? "";
            // experienceItems = List<Map<String, String>>.from(
            //     responseData['result']['experence'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Editable fields

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _pastExperienceController =
      TextEditingController();
  final TextEditingController _futurePlansController = TextEditingController();

  // Flag to toggle edit mode
  bool isEditing = false;

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

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = _nameController.text;
      bio = _bioController.text;
      linkedin = _linkedinController.text;
      about = _aboutController.text;
      pastExperience = _pastExperienceController.text;
      futurePlans = _futurePlansController.text;
      isEditing = false;
    });

    Map<String, dynamic> updatedUserData = {
      'name': name,
      'bio': bio,
      'linkedin': linkedin,
      'about': about,
      'pastExperience': pastExperience,
      'futurePlans': futurePlans,
    };

    prefs.setString('userDetails', json.encode(updatedUserData));
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
            // Stack to allow an overlay button for editing pictures
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: bgPic.isNotEmpty
                          ? NetworkImage(bgPic)
                          : const AssetImage('assets/images/default_bg.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                      backgroundColor: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/setup_profile_photo');
                    },
                    child: const Icon(Icons.edit, color: Colors.black),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (profilepic.isNotEmpty)
                            ? NetworkImage(profilepic)
                            : const AssetImage(
                                    'assets/images/default_profile_pic.png')
                                as ImageProvider,
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
                backgroundImage: (profilepic.isNotEmpty)
                    ? NetworkImage(profilepic)
                    : const AssetImage('assets/images/default_profile_pic.png')
                        as ImageProvider,
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
                      ][skills.indexOf(skill) % 4],
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
