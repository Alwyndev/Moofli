import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    if (userDataJson != null) {
      setState(() {
        userData = json.decode(userDataJson);
      });
      await _fetchProfile();
    } else {
      if (kDebugMode) print('User data not found in SharedPreferences');
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final responseData = await ApiService.fetchProfile();
      final DateFormat dateFormat = DateFormat("MMM yyyy");
      setState(() {
        var result = responseData['result'] ?? responseData;
        name = result['firstname'] ?? "";
        bio = result['about'] ?? "";
        linkedin = result['linkedinId'] ?? "";
        about = result['about'] ?? "";
        pastExperience = result['pastExp'] ?? "";
        futurePlans = result['futurePlans'] ?? "";
        profilepic = result['profilePicUrl'] ?? "";
        bgPic = result['bgPicUrl'] ?? "";

        // Process skills data.
        skills = [];
        var skillsData = result['skills'];
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
        List<dynamic>? experenceData = result['experence'];
        if (experenceData != null) {
          experienceItems = experenceData.map<Map<String, String>>((item) {
            String formattedStart = "";
            String formattedEnd = "";
            if (item["startDate"] != null &&
                item["startDate"].toString().isNotEmpty) {
              try {
                DateTime parsedStart = DateTime.parse(item["startDate"]);
                formattedStart = dateFormat.format(parsedStart);
              } catch (e) {
                formattedStart = "";
              }
            }
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
              "_id": item["_id"] ?? ""
            };
          }).toList();
        }

        // Process education data.
        List<dynamic>? educationData = result['education'];
        if (educationData != null) {
          educationItems = educationData.map<Map<String, String>>((item) {
            String degree = item["degree"] ?? "";
            String institution = item["institution"] ?? "";
            // For education, the backend might expect additional keys; adjust if needed.
            String endDate = item["endDate"] ?? "";
            return {
              "degree": degree,
              "institution": institution,
              "endDate": endDate,
            };
          }).toList();
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error fetching profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  void _toggleEdit(String field) {
    setState(() {
      switch (field) {
        case 'about':
          isEditingAbout = !isEditingAbout;
          if (isEditingAbout) _aboutController.text = about;
          break;
        case 'pastExperience':
          isEditingPastExperience = !isEditingPastExperience;
          if (isEditingPastExperience)
            _pastExperienceController.text = pastExperience;
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

  // Updated _updateFieldInBackend: For list/object fields ("experence", "skills", "education"),
  // we use updateMultipleProfileFields.
  Future<void> _updateFieldInBackend(String field, dynamic value) async {
    if (field == "experence" || field == "skills" || field == "education") {
      Map<String, dynamic> result =
          await ApiService.updateMultipleProfileFields({
        field: value,
      });
      if (result['success'] == true) {
        if (kDebugMode) print("$field updated successfully");
      } else {
        if (kDebugMode) print("Failed to update $field: ${result['message']}");
      }
    } else {
      bool success =
          await ApiService.updateProfileField(field, value.toString());
      if (kDebugMode) {
        print(success
            ? "$field updated successfully"
            : "Failed to update $field");
      }
    }
  }

  // For deletion of experience: if an item has an _id, call the dedicated delete endpoint.
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
      String id = experienceItems[index]["_id"] ?? "";
      if (id.isNotEmpty) {
        bool success = await ApiService.deleteExperience(id);
        if (success) {
          setState(() {
            experienceItems.removeAt(index);
          });
        } else {
          if (kDebugMode) print("Failed to delete experience via API");
        }
      } else {
        // Fallback: update entire list.
        setState(() {
          experienceItems.removeAt(index);
        });
        await _updateFieldInBackend("experence", experienceItems);
      }
    }
  }

  // For deletion of education.
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
      String id = educationItems[index]["_id"] ?? "";
      if (id.isNotEmpty) {
        bool success = await ApiService.deleteEducation(id);
        if (success) {
          setState(() {
            educationItems.removeAt(index);
          });
        } else {
          if (kDebugMode) print("Failed to delete education via API");
        }
      } else {
        setState(() {
          educationItems.removeAt(index);
        });
        await _updateFieldInBackend("education", educationItems);
      }
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
                    String rawEndDate =
                        isCurrent ? "Present" : endDateController.text.trim();
                    String endDate = rawEndDate.toLowerCase() == "present"
                        ? "Present"
                        : rawEndDate;
                    // For experience, use keys expected by the backend.
                    setState(() {
                      experienceItems.add({
                        "title": titleController.text,
                        "company": companyController.text,
                        "startDate": startDate,
                        "endDate": endDate,
                        // Optionally include "location" and "description" as empty strings if required.
                        "location": "",
                        "description": ""
                      });
                    });
                    _updateFieldInBackend("experence", experienceItems);
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
                    setState(() {
                      experienceItems[index] = {
                        "title": titleController.text,
                        "company": companyController.text,
                        "startDate": startDate,
                        "endDate": endDate,
                        "location": "",
                        "description": ""
                      };
                    });
                    _updateFieldInBackend("experence", experienceItems);
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
                _updateFieldInBackend("skills", skills);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
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
      _updateFieldInBackend("skills", skills);
    }
  }

  // Education: For simplicity, we update education via updateMultipleProfileFields.
  void _addEducation() async {
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
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
                setState(() {
                  // For education, we use keys expected by the backend.
                  educationItems.add({
                    "degree": degreeController.text,
                    "institution": institutionController.text,
                    "endDate": endYearController.text,
                  });
                });
                await _updateFieldInBackend("education", educationItems);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
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
          await _updateFieldInBackend("experence", experienceItems);
          setState(() {
            isEditingExperience = false;
          });
        }
        if (isEditingSkills) {
          await _updateFieldInBackend("skills", skills);
          setState(() {
            isEditingSkills = false;
          });
        }
        if (isEditingBio) await _saveField("bio");
        if (isEditingEducation) {
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

  Future<void> _refreshProfilePage() async {
    if (_hasUnsavedChanges()) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Unsaved Changes"),
            content: const Text(
                "You have unsaved changes. Would you like to save them before refreshing?"),
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
          await _updateFieldInBackend("experence", experienceItems);
          setState(() {
            isEditingExperience = false;
          });
        }
        if (isEditingSkills) {
          await _updateFieldInBackend("skills", skills);
          setState(() {
            isEditingSkills = false;
          });
        }
        if (isEditingBio) await _saveField("bio");
        if (isEditingEducation) {
          setState(() {
            isEditingEducation = false;
          });
        }
      }
    }
    await _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshProfilePage,
      child: GestureDetector(
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
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: bgPic.isNotEmpty
                                ? NetworkImage(bgPic)
                                : const AssetImage(
                                        'assets/images/default_bg.png')
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
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "Enter your bio"),
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
                                              await url_launcher.launchUrl(uri,
                                                  mode: url_launcher.LaunchMode
                                                      .externalApplication);
                                            }
                                          },
                                          child: Text(linkedin,
                                              style: TextStyle(
                                                  color: Colors.blue.shade800,
                                                  decoration: TextDecoration
                                                      .underline)),
                                        )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
      ),
    );
  }
}
