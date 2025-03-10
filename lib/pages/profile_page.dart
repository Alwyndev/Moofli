import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moofli_app/components/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../api/api_services.dart';

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
  List<Map<String, String>> educationItems = [];
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
  bool isEditingEducation = false;

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
      if (kDebugMode) print('User data not found in SharedPreferences');
    }
  }

  Future<void> _fetchProfile(String? token) async {
    if (token == null) {
      if (kDebugMode) print("Token is null");
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
          // Create a date formatter for displaying dates as "MMM yyyy".
          final DateFormat dateFormat = DateFormat("MMM yyyy");

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
                String formattedStart = "";
                String formattedEnd = "";
                // Parse and format start date if available.
                if (item["startDate"] != null &&
                    item["startDate"].toString().isNotEmpty) {
                  try {
                    DateTime parsedStart = DateTime.parse(item["startDate"]);
                    formattedStart = dateFormat.format(parsedStart);
                  } catch (e) {
                    formattedStart = "";
                  }
                }
                // Parse and format end date if available; if not, use "Present".
                if (item["endDate"] != null &&
                    item["endDate"].toString().isNotEmpty) {
                  try {
                    DateTime parsedEnd = DateTime.parse(item["endDate"]);
                    formattedEnd = dateFormat.format(parsedEnd);
                  } catch (e) {
                    formattedEnd = "Present";
                  }
                } else {
                  formattedEnd = "Present";
                }
                String duration = "";
                if (formattedStart.isNotEmpty || formattedEnd.isNotEmpty) {
                  duration = "$formattedStart - $formattedEnd";
                }
                return {
                  "title": item["title"] ?? "",
                  "company": item["company"] ?? "",
                  "startDate": formattedStart,
                  "endDate": formattedEnd,
                  "duration": duration,
                  // Preserving _id if needed for future operations.
                  "_id": item["_id"] ?? ""
                };
              }).toList();
            }

            // Process education data.
            List<dynamic>? educationData = responseData['result']['education'];
            if (educationData != null) {
              educationItems = educationData.map<Map<String, String>>((item) {
                String degree = item["degree"] ?? "";
                String institution = item["institution"] ?? "";
                String duration = item["duration"] ?? "";
                return {
                  "degree": degree,
                  "institution": institution,
                  "duration": duration,
                };
              }).toList();
            }
          });
        }
      } else {
        if (kDebugMode) print("Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching profile: $e');
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

  // Toggle editing mode for specific fields.
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
        case 'bio':
          isEditingBio = !isEditingBio;
          if (isEditingBio) _bioController.text = bio;
          break;
      }
    });
  }

  // Save the updated field locally and in the backend.
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
        case 'bio':
          bio = _bioController.text;
          newValue = bio;
          isEditingBio = false;
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

  // Update a field on the backend for simple text fields.
  Future<void> _updateFieldInBackend(String field, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      if (kDebugMode) print("Token is null");
      return;
    }
    if (field == "skills") {
      try {
        List<dynamic> skillsList = json.decode(value);
        List<String> titleCaseSkills =
            skillsList.map((skill) => toTitleCase(skill.toString())).toList();
        value = json.encode(titleCaseSkills);
      } catch (e) {
        if (kDebugMode) print("Error processing skills for title case: $e");
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
        if (kDebugMode) print("$field updated successfully");
      } else {
        if (kDebugMode) print("Failed to update $field: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("Error updating $field: $e");
    }
  }

  // Helper function to update education details using the new API function.
  Future<void> _updateEducationInBackend(
      List<Map<String, dynamic>> educationItem) async {
    bool success = await ApiService.updateEducationDetails(educationItem);
    if (success) {
      if (kDebugMode) print("Education updated successfully");
    } else {
      if (kDebugMode) print("Failed to update education");
    }
  }

  // Shows a dialog to add a new experience.
  void _addExperience() async {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    bool isCurrent = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                      controller: startDateController,
                      decoration: const InputDecoration(
                          hintText: "Start Date (e.g., Mar 2022)"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              hintText: isCurrent
                                  ? "Present"
                                  : "End Date (e.g., Dec 2023)",
                            ),
                            enabled: !isCurrent,
                          ),
                        ),
                        Checkbox(
                          value: isCurrent,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              isCurrent = value ?? false;
                            });
                          },
                        ),
                        const Text("Current")
                      ],
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
                    String startDate = startDateController.text.trim();
                    // Force end date to "Present" if current or if user enters "present".
                    String rawEndDate =
                        isCurrent ? "Present" : endDateController.text.trim();
                    String endDate = rawEndDate.toLowerCase() == "present"
                        ? "Present"
                        : rawEndDate;
                    String duration = "$startDate - $endDate";
                    setState(() {
                      experienceItems.add({
                        "title": titleController.text,
                        "company": companyController.text,
                        "startDate": startDate,
                        "endDate": endDate,
                        "duration": duration,
                      });
                    });
                    _updateFieldInBackend(
                        "experence", jsonEncode(experienceItems));
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Shows a dialog to edit an existing experience item.
  void _editExperience(int index) async {
    final titleController =
        TextEditingController(text: experienceItems[index]["title"]);
    final companyController =
        TextEditingController(text: experienceItems[index]["company"]);
    final startDateController =
        TextEditingController(text: experienceItems[index]["startDate"] ?? "");
    final endDateController =
        TextEditingController(text: experienceItems[index]["endDate"] ?? "");
    bool isCurrent = false;
    if ((experienceItems[index]["endDate"] ?? "").toLowerCase() == "present") {
      isCurrent = true;
      endDateController.text = "";
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Experience"),
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
                      controller: startDateController,
                      decoration: const InputDecoration(
                          hintText: "Start Date (e.g., Mar 2022)"),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              hintText: isCurrent
                                  ? "Present"
                                  : "End Date (e.g., Dec 2023)",
                            ),
                            enabled: !isCurrent,
                          ),
                        ),
                        Checkbox(
                          value: isCurrent,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              isCurrent = value ?? false;
                            });
                          },
                        ),
                        const Text("Current")
                      ],
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
                    String startDate = startDateController.text.trim();
                    String rawEndDate =
                        isCurrent ? "Present" : endDateController.text.trim();
                    String endDate = rawEndDate.toLowerCase() == "present"
                        ? "Present"
                        : rawEndDate;
                    String duration = "$startDate - $endDate";
                    setState(() {
                      experienceItems[index] = {
                        "title": titleController.text,
                        "company": companyController.text,
                        "startDate": startDate,
                        "endDate": endDate,
                        "duration": duration,
                      };
                    });
                    _updateFieldInBackend(
                        "experence", jsonEncode(experienceItems));
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
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
      _updateFieldInBackend("experence", jsonEncode(experienceItems));
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

  // Updated Education dialog with separate fields for Degree, Institution, Start Year, and End Year.
  void _addEducation() async {
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Education"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(hintText: "Degree"),
                ),
                TextField(
                  controller: institutionController,
                  decoration: const InputDecoration(hintText: "Institution"),
                ),
                TextField(
                  controller: startYearController,
                  decoration: const InputDecoration(hintText: "Start Year"),
                ),
                TextField(
                  controller: endYearController,
                  decoration: const InputDecoration(hintText: "End Year"),
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
              onPressed: () async {
                String startYear = startYearController.text.trim();
                String endYear = endYearController.text.trim();
                String duration = "$startYear - $endYear";
                setState(() {
                  educationItems.add({
                    "degree": degreeController.text,
                    "institution": institutionController.text,
                    "duration": duration,
                  });
                });
                await _updateEducationInBackend(educationItems);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteEducation(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Education"),
          content: const Text(
              "Are you sure you want to delete this education entry?"),
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
        educationItems.removeAt(index);
      });
      await _updateEducationInBackend(educationItems);
    }
  }

  bool _hasUnsavedChanges() {
    return isEditingAbout ||
        isEditingPastExperience ||
        isEditingFuturePlans ||
        isEditingExperience ||
        isEditingSkills ||
        isEditingBio ||
        isEditingEducation;
  }

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
        if (isEditingAbout) await _saveField("about");
        if (isEditingPastExperience) await _saveField("pastExperience");
        if (isEditingFuturePlans) await _saveField("futurePlans");
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
        if (isEditingBio) await _saveField("bio");
        if (isEditingEducation) {
          await _updateEducationInBackend(educationItems);
          setState(() {
            isEditingEducation = false;
          });
        }
      }
    }
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
      _handleSaveAndNavigate();
    }
  }

  /// Returns the combined bio which includes only the summary of the first experience
  /// and first education item, removing the about section.
  String _combinedBio() {
    String combined = "";
    if (experienceItems.isNotEmpty) {
      combined +=
          "Experience: ${experienceItems[0]['title'] ?? ''} at ${experienceItems[0]['company'] ?? ''}";
    }
    if (educationItems.isNotEmpty) {
      if (combined.isNotEmpty) combined += "\n";
      combined +=
          "Education: ${educationItems[0]['degree'] ?? ''} from ${educationItems[0]['institution'] ?? ''}";
    }
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalSwipe,
      child: WillPopScope(
        onWillPop: () async {
          await _handleSaveAndNavigate();
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
                      bottom: 8,
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
                      // Profile picture, name, and bio.
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
                                Text(name,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: isEditingBio
                                          ? TextField(
                                              controller: _bioController,
                                              decoration: const InputDecoration(
                                                  hintText: "Enter your bio"),
                                            )
                                          : (_combinedBio().trim().isEmpty
                                              ? const Text("No bio provided.",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic))
                                              : Text(_combinedBio(),
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
                                    : InkWell(
                                        onTap: () async {
                                          final uri = Uri.parse(linkedin);
                                          if (await url_launcher
                                              .canLaunchUrl(uri)) {
                                            await url_launcher.launchUrl(uri);
                                          }
                                        },
                                        child: Text(linkedin,
                                            style: TextStyle(
                                              color: Colors.blue.shade800,
                                              decoration:
                                                  TextDecoration.underline,
                                            )),
                                      )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Editable sections.
                      buildEditableSection(
                        title: "ABOUT",
                        content: about,
                        isEditing: isEditingAbout,
                        controller: _aboutController,
                        field: "about",
                        onToggleEdit: () => _toggleEdit("about"),
                        onSave: () => _saveField("about"),
                      ),
                      buildEditableSection(
                        title: "Past Experience",
                        content: pastExperience,
                        isEditing: isEditingPastExperience,
                        controller: _pastExperienceController,
                        field: "pastExperience",
                        onToggleEdit: () => _toggleEdit("pastExperience"),
                        onSave: () => _saveField("pastExperience"),
                      ),
                      buildEditableSection(
                        title: "Future Plans",
                        content: futurePlans,
                        isEditing: isEditingFuturePlans,
                        controller: _futurePlansController,
                        field: "futurePlans",
                        onToggleEdit: () => _toggleEdit("futurePlans"),
                        onSave: () => _saveField("futurePlans"),
                      ),
                      // Experience section.
                      buildExperienceSection(
                        isEditingExperience: isEditingExperience,
                        experienceItems: experienceItems,
                        onToggleEdit: () {
                          setState(() {
                            isEditingExperience = !isEditingExperience;
                          });
                        },
                        onAddExperience: _addExperience,
                        onDeleteExperience: (index) =>
                            _confirmDeleteExperience(index),
                        onEditExperience: _editExperience,
                      ),
                      // Skills section.
                      buildSkillsSection(
                        isEditingSkills: isEditingSkills,
                        skills: skills,
                        onToggleEdit: () {
                          setState(() {
                            isEditingSkills = !isEditingSkills;
                          });
                        },
                        onAddSkill: _addSkill,
                        onDeleteSkill: (index) => _confirmDeleteSkill(index),
                      ),
                      // Education section.
                      buildEducationSection(
                        isEditingEducation: isEditingEducation,
                        educationItems: educationItems,
                        onToggleEdit: () {
                          setState(() {
                            isEditingEducation = !isEditingEducation;
                          });
                        },
                        onAddEducation: _addEducation,
                        onDeleteEducation: (index) =>
                            _confirmDeleteEducation(index),
                      ),
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
}
