import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that displays text with an expandable behavior.
/// Initially it shows only [initialLines] (default 3) of text. If the text overflows,
/// a “Read more” option appears that increases the max lines by 15.
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int initialLines;
  const ExpandableTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.initialLines = 3,
  }) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late int _currentMaxLines;

  @override
  void initState() {
    super.initState();
    _currentMaxLines = widget.initialLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final textSpan = TextSpan(text: widget.text, style: widget.style);
      final tp = TextPainter(
        text: textSpan,
        maxLines: _currentMaxLines,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: constraints.maxWidth);
      final didOverflow = tp.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            maxLines: _currentMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          if (didOverflow)
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentMaxLines += 15;
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "Read more",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
        ],
      );
    });
  }
}

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

  // Editing flags for each section.
  bool isEditingBio = false;
  bool isEditingLinkedIn = false;
  bool isEditingAbout = false;
  bool isEditingPastExperience = false;
  bool isEditingFuturePlans = false;
  bool isEditingExperience = false;
  bool isEditingSkills = false;

  // Helper method to convert strings to Title Case.
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

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
            bio = responseData['result']['about'] ?? "";
            linkedin = responseData['result']['linkedinId'] ?? "";
            about = responseData['result']['about'] ?? "";
            pastExperience = responseData['result']['pastExp'] ?? "";
            futurePlans = responseData['result']['futurePlans'] ?? "";
            profilepic = responseData['result']['profilePicUrl'] ?? "";
            bgPic = responseData['result']['bgPicUrl'] ?? "";

            // Process skills data.
            skills = [];
            var skillsData = responseData['result']['skills'];
            if (skillsData != null) {
              String skillsStr = skillsData
                  .toString()
                  .replaceAll(RegExp(r'[\[\]"]'), '')
                  .replaceAll('\\', '')
                  .trim();
              if (skillsStr.isNotEmpty) {
                skills = skillsStr
                    .split(',')
                    .map((s) => toTitleCase(s.trim()))
                    .where((s) => s.isNotEmpty)
                    .toList();
              }
            }

            // Process experience data.
            List<dynamic>? experenceData = responseData['result']['experence'];
            if (experenceData != null) {
              experienceItems = experenceData.map<Map<String, String>>((item) {
                String startDate = item["startDate"] ?? "";
                String endDate = item["endDate"] ?? "";
                String duration = startDate.isNotEmpty
                    ? (endDate.isNotEmpty
                        ? "$startDate - $endDate"
                        : "$startDate - Present")
                    : "";
                return {
                  "title": item["title"] ?? "",
                  "company": item["company"] ?? "",
                  "duration": duration,
                };
              }).toList();
            }
          });
        }
      } else {
        if (kDebugMode) {
          print("Failed to fetch profile: ${response.body}");
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

    String? userDetailsJson = prefs.getString('userDetails');
    Map<String, dynamic> updatedUserData = {};
    if (userDetailsJson != null) {
      updatedUserData = json.decode(userDetailsJson);
    }
    updatedUserData[field] = newValue;
    prefs.setString('userDetails', json.encode(updatedUserData));

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

    if (field == "skills") {
      try {
        List<dynamic> skillsList = json.decode(value);
        List<String> titleCaseSkills =
            skillsList.map((skill) => toTitleCase(skill.toString())).toList();
        value = json.encode(titleCaseSkills);
      } catch (e) {
        if (kDebugMode) {
          print("Error processing skills for title case: $e");
        }
      }
    }

    var uri = Uri.parse("https://skillop.in/api/user/update/profile");
    var request = http.MultipartRequest("PUT", uri);
    request.headers['authorization'] = token;

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
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(
                    hintText: "Duration (e.g., Mar 2020 - Dec 2023)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String durationInput = durationController.text.trim();
                List<String> parts = durationInput.split('-');
                String startDate = "";
                String endDate = "";
                if (parts.length == 2) {
                  startDate = parts[0].trim();
                  endDate = parts[1].trim();
                }

                setState(() {
                  experienceItems.add({
                    "title": titleController.text,
                    "company": companyController.text,
                    "startDate": startDate,
                    "endDate": endDate,
                    "duration": durationInput,
                  });
                });
                _updateFieldInBackend("experence", jsonEncode(experienceItems));
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
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  skills.add(toTitleCase(skillController.text));
                });
                Navigator.pop(context);
                _updateFieldInBackend("skills", jsonEncode(skills));
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
      _updateFieldInBackend("skills", jsonEncode(skills));
    }
  }

  // Checks if any editing flags indicate unsaved changes.
  bool _hasUnsavedChanges() {
    return isEditingAbout ||
        isEditingPastExperience ||
        isEditingFuturePlans ||
        isEditingExperience ||
        isEditingSkills;
  }

  // Handles saving (or discarding) unsaved changes and navigates back to Home.
  Future<void> _handleSaveAndNavigate() async {
    if (_hasUnsavedChanges()) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Unsaved Changes"),
            content: const Text(
                "You have unsaved changes. Would you like to save them before leaving?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "cancel"),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "discard"),
                child: const Text("Discard"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "save"),
                child: const Text("Save"),
              ),
            ],
          );
        },
      );

      if (result == "cancel") {
        return;
      } else if (result == "save") {
        if (isEditingAbout) {
          await _saveField("about");
        }
        if (isEditingPastExperience) {
          await _saveField("pastExperience");
        }
        if (isEditingFuturePlans) {
          await _saveField("futurePlans");
        }
        if (isEditingExperience) {
          await _updateFieldInBackend("experence", jsonEncode(experienceItems));
          setState(() {
            isEditingExperience = false;
          });
        }
        if (isEditingSkills) {
          await _updateFieldInBackend("skills", jsonEncode(skills));
          setState(() {
            isEditingSkills = false;
          });
        }
      }
    }
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  // Detects horizontal swipe gesture (right-swipe) to trigger save prompt and navigate.
  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
      _handleSaveAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalSwipe,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(
              context, "/home", (Route<dynamic> route) => false);
          return false;
        },
        child: Scaffold(
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
                        onPressed: () => Navigator.pushNamed(
                            context, '/setup_profile_photo'),
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
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
                                          : (bio.trim().isEmpty
                                              ? const Text("No bio provided.",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic))
                                              : Text(bio,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey))),
                                    ),
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
                                : (linkedin.trim().isEmpty
                                    ? const Text("No LinkedIn URL provided.",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic))
                                    : Text(
                                        linkedin,
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          decoration: TextDecoration.underline,
                                        ),
                                      )),
                          ),
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
                icon: const Icon(Icons.home, color: Colors.black, size: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  backgroundImage: profilepic.isNotEmpty
                      ? NetworkImage(profilepic)
                      : const AssetImage(
                              'assets/images/default_profile_pic.png')
                          as ImageProvider,
                ),
                label: '',
              ),
            ],
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/home", (Route<dynamic> route) => false);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Reusable widget for editable text sections.
  /// For sections other than experience/education (here, we assume "pastExperience" is treated as experience),
  /// if the content is longer than three lines, it shows only a truncated view with a "Read more" option.
  Widget buildEditableSection(String title, String content,
      TextEditingController controller, bool isEditing, String field) {
    Widget displayWidget = const SizedBox.shrink();
    if (!isEditing) {
      if (content.trim().isEmpty) {
        displayWidget = Text(
          "No information provided for $title.",
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        );
      } else if (field == "about" || field == "futurePlans") {
        // Apply expandable behavior for non-experience sections.
        displayWidget = ExpandableTextWidget(
          text: content,
          style: const TextStyle(fontSize: 14),
        );
      } else {
        // For fields like pastExperience (considered as experience), show full text.
        displayWidget = Text(content, style: const TextStyle(fontSize: 14));
      }
    }

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
                  maxLines: null,
                  decoration: InputDecoration(hintText: "Enter $title"),
                )
              : displayWidget,
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
                  Colors.purple,
                ][skills.indexOf(skill) % 5],
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
