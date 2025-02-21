import 'dart:convert';
// import 'dart:io'; // For file upload (if needed)
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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

  // Editing flags for each section
  bool isEditingBio = false;
  bool isEditingLinkedIn = false;
  bool isEditingAbout = false;
  bool isEditingPastExperience = false;
  bool isEditingFuturePlans = false;
  bool isEditingExperience = false;
  bool isEditingSkills = false;

  // For profile image update.
  // File? _profileImageFile;

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
      if (kDebugMode) {
        print('User data not found in SharedPreferences');
      }
    }
  }

  Future<void> _fetchProfile(String? token) async {
    if (token == null) {
      if (kDebugMode) {
        print("Token is null");
      }
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://skillop.in/api/user/profile/me'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            name = responseData['result']['firstname'] ?? "";
            // Both bio and about come from the same field in your API.
            bio = responseData['result']['about'] ?? "";
            linkedin = responseData['result']['linkedinId'] ?? "";
            about = responseData['result']['about'] ?? "";
            pastExperience = responseData['result']['pastExp'] ?? "";
            futurePlans = responseData['result']['futurePlans'] ?? "";
            profilepic = responseData['result']['profilePicUrl'] ?? "";
            bgPic = responseData['result']['bgPicUrl'] ?? "";

            // Decode the skills field.
            var skillsData = responseData['result']['skills'];
            if (skillsData is String) {
              try {
                // Try decoding as JSON.
                var decoded = json.decode(skillsData);
                if (decoded is List) {
                  skills = List<String>.from(decoded);
                }
              } catch (e) {
                // Fallback: remove brackets and quotes, then split.
                skills = skillsData
                    .replaceAll(RegExp(r'[\[\]"]'), '')
                    .split(',')
                    .map((s) => s.trim())
                    .toList();
              }
            } else if (skillsData is List) {
              skills = List<String>.from(skillsData);
            }

            // Uncomment if you wish to load experience items:
            // experienceItems = List<Map<String, String>>.from(responseData['result']['experence'] ?? []);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Controllers for text fields.
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _pastExperienceController =
      TextEditingController();
  final TextEditingController _futurePlansController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _linkedinController.dispose();
    _aboutController.dispose();
    _pastExperienceController.dispose();
    _futurePlansController.dispose();
    super.dispose();
  }

  /// Toggles editing mode for a section.
  void _toggleEdit(String field) {
    setState(() {
      switch (field) {
        // Uncomment for bio or LinkedIn.
        // case 'bio':
        //   isEditingBio = !isEditingBio;
        //   if (isEditingBio) _bioController.text = bio;
        //   break;
        // case 'linkedin':
        //   isEditingLinkedIn = !isEditingLinkedIn;
        //   if (isEditingLinkedIn) _linkedinController.text = linkedin;
        //   break;
        case 'about':
          isEditingAbout = !isEditingAbout;
          if (isEditingAbout) _aboutController.text = about;
          break;
        case 'pastExperience':
          isEditingPastExperience = !isEditingPastExperience;
          if (isEditingPastExperience) {
            _pastExperienceController.text = pastExperience;
          }
          break;
        case 'futurePlans':
          isEditingFuturePlans = !isEditingFuturePlans;
          if (isEditingFuturePlans) _futurePlansController.text = futurePlans;
          break;
      }
    });
  }

  /// Saves the updated field locally and then updates the backend.
  Future<void> _saveField(String field) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newValue = "";
    setState(() {
      switch (field) {
        // case 'bio':
        //   bio = _bioController.text;
        //   newValue = bio;
        //   isEditingBio = false;
        //   break;
        // case 'linkedin':
        //   linkedin = _linkedinController.text;
        //   newValue = linkedin;
        //   isEditingLinkedIn = false;
        //   break;
        case 'about':
          about = _aboutController.text;
          newValue = about;
          isEditingAbout = false;
          break;
        case 'pastExperience':
          pastExperience = _pastExperienceController.text;
          newValue = pastExperience;
          isEditingPastExperience = false;
          break;
        case 'futurePlans':
          futurePlans = _futurePlansController.text;
          newValue = futurePlans;
          isEditingFuturePlans = false;
          break;
      }
    });

    // Update local SharedPreferences.
    String? userDetailsJson = prefs.getString('userDetails');
    Map<String, dynamic> updatedUserData = {};
    if (userDetailsJson != null) {
      updatedUserData = json.decode(userDetailsJson);
    }
    updatedUserData[field] = newValue;
    prefs.setString('userDetails', json.encode(updatedUserData));

    // Now update the backend for this field.
    await _updateFieldInBackend(field, newValue);
  }

  /// Updates a single field on the backend using the update profile API.
  Future<void> _updateFieldInBackend(String field, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      if (kDebugMode) {
        print("Token is null");
      }
      return;
    }
    var uri = Uri.parse("https://skillop.in/api/user/update/profile");
    var request = http.MultipartRequest("PUT", uri);
    request.headers['authorization'] = token;

    // Map 'pastExperience' to 'pastExp' since the API expects 'pastExp'
    String fieldKey = (field == 'pastExperience') ? 'pastExp' : field;
    request.fields[fieldKey] = value;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("$field updated successfully");
        }
      } else {
        if (kDebugMode) {
          print("Failed to update $field: ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating $field: $e");
      }
    }
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
              onPressed: () => Navigator.pop(context),
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
              onPressed: () => Navigator.pop(context),
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
      // No global save button – each section saves individually.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background image with edit button.
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
                    onPressed: () =>
                        Navigator.pushNamed(context, '/setup_profile_photo'),
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
                  // Profile picture, name, and bio section.
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profilepic.isNotEmpty
                            ? NetworkImage(profilepic)
                            : const AssetImage(
                                    'assets/images/default_profile_pic.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: isEditingBio
                                      ? TextField(
                                          controller: _bioController,
                                          decoration: const InputDecoration(
                                            hintText: "Enter your bio",
                                          ),
                                        )
                                      : Text(
                                          bio,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                ),
                                // Uncomment below to allow bio editing.
                                // IconButton(
                                //   icon: Icon(isEditingBio ? Icons.save : Icons.edit, size: 16),
                                //   onPressed: () {
                                //     if (isEditingBio) {
                                //       _saveField('bio');
                                //     } else {
                                //       _toggleEdit('bio');
                                //     }
                                //   },
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // LinkedIn row.
                  Row(
                    children: [
                      const Icon(Icons.link),
                      const SizedBox(width: 8),
                      Expanded(
                        child: isEditingLinkedIn
                            ? TextField(
                                controller: _linkedinController,
                                decoration: const InputDecoration(
                                    hintText: "Enter LinkedIn URL"),
                              )
                            : Text(
                                linkedin,
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                      // Uncomment to allow LinkedIn editing.
                      // IconButton(
                      //   icon: Icon(isEditingLinkedIn ? Icons.save : Icons.edit, size: 16),
                      //   onPressed: () {
                      //     if (isEditingLinkedIn) {
                      //       _saveField('linkedin');
                      //     } else {
                      //       _toggleEdit('linkedin');
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Editable text sections.
                  buildEditableSection("ABOUT", about, _aboutController,
                      isEditingAbout, "about"),
                  buildEditableSection(
                      "Past Experience",
                      pastExperience,
                      _pastExperienceController,
                      isEditingPastExperience,
                      "pastExperience"),
                  buildEditableSection(
                      "Future Plans",
                      futurePlans,
                      _futurePlansController,
                      isEditingFuturePlans,
                      "futurePlans"),
                  // Experience section.
                  buildExperienceSection(),
                  // Skills section.
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
              onTap: () => Navigator.pushNamed(context, "/home"),
              child: const Icon(Icons.home, color: Colors.black, size: 40),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                backgroundImage: profilepic.isNotEmpty
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

  /// Reusable widget for editable text sections.
  Widget buildEditableSection(String title, String content,
      TextEditingController controller, bool isEditing, String field) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with edit/save icon.
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(isEditing ? Icons.save : Icons.edit, size: 16),
                onPressed: () {
                  if (isEditing) {
                    _saveField(field);
                  } else {
                    _toggleEdit(field);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter $title"))
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
          // Header with edit/save icon and add button.
          Row(
            children: [
              const Text("EXPERIENCE",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(isEditingExperience ? Icons.save : Icons.edit,
                    size: 16),
                onPressed: () {
                  if (isEditingExperience) {
                    setState(() {
                      isEditingExperience = false;
                    });
                    _updateFieldInBackend(
                        "experence", jsonEncode(experienceItems));
                  } else {
                    setState(() {
                      isEditingExperience = true;
                    });
                  }
                },
              ),
              if (isEditingExperience)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue, size: 16),
                  onPressed: _addExperience,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: experienceItems.asMap().entries.map((entry) {
              return buildExperienceItem(
                entry.value["title"]!,
                entry.value["company"]!,
                entry.value["duration"]!,
                entry.key,
              );
            }).toList(),
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(company,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(duration,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          if (isEditingExperience)
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
          // Header with edit/save icon and add button.
          Row(
            children: [
              const Text("SKILLS",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(isEditingSkills ? Icons.save : Icons.edit, size: 16),
                onPressed: () {
                  if (isEditingSkills) {
                    setState(() {
                      isEditingSkills = false;
                    });
                    _updateFieldInBackend("skills", jsonEncode(skills));
                  } else {
                    setState(() {
                      isEditingSkills = true;
                    });
                  }
                },
              ),
              if (isEditingSkills)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue, size: 16),
                  onPressed: _addSkill,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Each skill will be shown as an individual chip.
          Wrap(
            spacing: 8,
            children: skills.map((skill) {
              return buildSkillChip(
                skill,
                [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                ][skills.indexOf(skill) % 4],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildSkillChip(String label, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.15),
      onDeleted: isEditingSkills
          ? () => _confirmDeleteSkill(skills.indexOf(label))
          : null,
      label: Text(label, style: const TextStyle(color: Colors.black)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color, width: 2),
      ),
    );
  }
}
