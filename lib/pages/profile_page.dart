import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moofli_app/components/helper_functions.dart';
import 'package:moofli_app/pages/setup_profile/setup_profile_upload_photo.dart';
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
      final DateFormat dateFormat = DateFormat("MMM yyyy", "en_US");
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
                item["endDate"].toString().isNotEmpty &&
                item["endDate"].toString().toLowerCase() != "present") {
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
              "startDate": item["startDate"] ?? "",
              "endDate": item["endDate"] ?? "",
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
            String endDate = item["endDate"] ?? "";
            // Format endDate to display year only.
            String duration = "";
            try {
              DateTime date = DateTime.parse(endDate);
              duration = DateFormat("yyyy").format(date);
            } catch (e) {
              duration = endDate;
            }
            return {
              "degree": degree,
              "institution": institution,
              "endDate": endDate,
              "fieldOfStudy": item["fieldOfStudy"] ?? "",
              "duration": duration,
              "_id": item["_id"] ?? ""
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

  // For list/object fields ("experence", "skills", "education"), we use updateMultipleProfileFields.
  Future<void> _updateFieldInBackend(String field, dynamic value) async {
    try {
      dynamic sendValue = value;
      if (field == "experence" || field == "skills" || field == "education") {
        if (field == "experence" && value is List) {
          sendValue = value.map((item) {
            if (item is Map<String, dynamic>) {
              if (item['endDate'] == "Present") {
                item = Map<String, dynamic>.from(item);
                item.remove('endDate');
              }
            }
            return item;
          }).toList();
        }
        Map<String, dynamic> result =
            await ApiService.updateMultipleProfileFields({
          field: json.encode(sendValue),
        });
        if (result['success'] == true) {
          if (kDebugMode) print("$field updated successfully");
        } else {
          if (kDebugMode)
            print("Failed to update $field: ${result['message']}");
        }
      } else {
        bool success =
            await ApiService.updateProfileField(field, value.toString());
        if (kDebugMode) {
          if (success) {
            print("$field updated successfully");
          } else {
            print("Failed to update $field");
          }
        }
      }
    } catch (error) {
      if (kDebugMode) print("Error updating $field: $error");
    }
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
        setState(() {
          experienceItems.removeAt(index);
        });
        await _updateFieldInBackend("experence", experienceItems);
      }
    }
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

  // --- ADD EXPERIENCE ---
  Future<void> _addExperience() async {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool isCurrent = false;
    final inputFormat = DateFormat("MMM yyyy", "en_US");

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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Start Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setStateDialog(() {
                                  startDate = pickedDate;
                                  startDateController.text =
                                      inputFormat.format(pickedDate);
                                  print("Selected startDate: $pickedDate");
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "End Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: isCurrent
                                ? null
                                : () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setStateDialog(() {
                                        endDate = pickedDate;
                                        endDateController.text =
                                            inputFormat.format(pickedDate);
                                        print("Selected endDate: $pickedDate");
                                      });
                                    }
                                  },
                          ),
                        ),
                        Checkbox(
                          value: isCurrent,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              isCurrent = value ?? false;
                              if (isCurrent) {
                                endDateController.text = "Present";
                                endDate = null;
                                print("Marked as current: endDate = Present");
                              } else {
                                endDateController.clear();
                                print("Unmarked current: endDate cleared");
                              }
                            });
                          },
                        ),
                        const Text("Current"),
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
                  onPressed: () async {
                    String isoStart =
                        startDate != null ? startDate!.toIso8601String() : "";
                    String isoEnd = isCurrent
                        ? "Present"
                        : endDate != null
                            ? endDate!.toIso8601String()
                            : "";

                    String duration = "";
                    try {
                      String formattedStart = startDateController.text;
                      duration = isCurrent
                          ? "$formattedStart - Present"
                          : "$formattedStart - ${endDateController.text}";
                    } catch (e) {
                      print("Error formatting duration: $e");
                    }

                    // Debug: show the experience item about to be added.
                    Map<String, String> newExpItem = {
                      "title": titleController.text.trim(),
                      "company": companyController.text.trim(),
                      "startDate": isoStart,
                      "endDate": isoEnd,
                      "location": "",
                      "description": "",
                      "_id": UniqueKey().toString(),
                      "duration": duration,
                    };
                    print("New experience item: $newExpItem");

                    setState(() {
                      experienceItems.add(newExpItem);
                    });

                    // Debug: show full list before update.
                    print(
                        "Experience items before backend update: $experienceItems");

                    // Call the function to update the backend (ensure the endpoint is correct)
                    await _updateExperienceInBackend(experienceItems);

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

  Future<void> _updateExperienceInBackend(
      List<Map<String, dynamic>> experienceItems) async {
    final url = 'https://skillop.in/api/user/update/profile';

    // Prepare cleaned experience list
    List<Map<String, dynamic>> cleanedList = experienceItems.map((item) {
      return {
        "title": item["title"] ?? "",
        "company": item["company"] ?? "",
        "location": item["location"] ?? "",
        "startDate": "1995", //item["startDate"] ?? ""
        "endDate": "2025", //item["endDate"] ?? ""
        "description": item["description"] ?? "",
      };
    }).toList();

    Map<String, dynamic> payload = {
      'experence': cleanedList,
    };

    print("Cleaned Payload being sent to backend: ${jsonEncode(payload)}");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print("Experience updated successfully! Response: ${response.body}");
    } else {
      print("Failed to update experience. Status code: ${response.statusCode}");
      print("Backend error: ${response.body}");
    }
  }

// --- EDIT EXPERIENCE ---
  void _editExperience(int index) async {
    final titleController =
        TextEditingController(text: experienceItems[index]["title"]);
    final companyController =
        TextEditingController(text: experienceItems[index]["company"]);
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final inputFormat = DateFormat("MMM yyyy", "en_US");

    try {
      startDate = DateTime.parse(experienceItems[index]["startDate"]!);
      startDateController.text = inputFormat.format(startDate);
    } catch (e) {
      print("Error parsing startDate: $e");
    }

    bool isCurrent =
        experienceItems[index]["endDate"]?.toLowerCase() == "present";
    if (!isCurrent) {
      try {
        endDate = DateTime.parse(experienceItems[index]["endDate"]!);
        endDateController.text = inputFormat.format(endDate);
      } catch (e) {
        print("Error parsing endDate: $e");
      }
    } else {
      endDateController.text = "Present";
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Start Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setStateDialog(() {
                                  startDate = pickedDate;
                                  startDateController.text =
                                      inputFormat.format(pickedDate);
                                  print("New startDate selected: $pickedDate");
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "End Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: isCurrent
                                ? null
                                : () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: endDate ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setStateDialog(() {
                                        endDate = pickedDate;
                                        endDateController.text =
                                            inputFormat.format(pickedDate);
                                        print(
                                            "New endDate selected: $pickedDate");
                                      });
                                    }
                                  },
                          ),
                        ),
                        Checkbox(
                          value: isCurrent,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              isCurrent = value ?? false;
                              if (isCurrent) {
                                endDateController.text = "Present";
                                endDate = null;
                                print("Set to current: endDate = Present");
                              } else {
                                endDateController.clear();
                                print("Unset current: endDate cleared");
                              }
                            });
                          },
                        ),
                        const Text("Current"),
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
                    String isoStart =
                        startDate != null ? startDate!.toIso8601String() : "";
                    String isoEnd = isCurrent
                        ? "Present"
                        : endDate != null
                            ? endDate!.toIso8601String()
                            : "";

                    String duration = "";
                    try {
                      String formattedStart = startDateController.text;
                      duration = isCurrent
                          ? "$formattedStart - Present"
                          : "$formattedStart - ${endDateController.text}";
                    } catch (e) {
                      print("Error formatting duration during edit: $e");
                    }

                    setState(() {
                      experienceItems[index] = {
                        "title": titleController.text.trim(),
                        "company": companyController.text.trim(),
                        "startDate": isoStart,
                        "endDate": isoEnd,
                        "location": "",
                        "description": "",
                        "_id": experienceItems[index]["_id"] ??
                            UniqueKey().toString(),
                        "duration": duration,
                      };
                    });

                    // Debug: Print updated experience item and full list
                    print(
                        "Updated experience item at index $index: ${experienceItems[index]}");
                    print(
                        "Experience items before backend update: $experienceItems");

                    // Update the backend with the new data.
                    _updateExperienceInBackend(experienceItems);
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
                  decoration:
                      const InputDecoration(hintText: "End Year (e.g., 2020)"),
                  keyboardType: TextInputType.number,
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
                // Convert the entered year to an ISO date (using January 1 as default)
                DateTime endDate =
                    DateTime(int.parse(endYearController.text.trim()), 1, 1);
                String isoEndDate = endDate.toIso8601String();
                setState(() {
                  educationItems.add({
                    "degree": degreeController.text.trim(),
                    "institution": institutionController.text.trim(),
                    "fieldOfStudy": "", // Added for consistency.
                    "endDate": isoEndDate,
                    "_id": UniqueKey().toString(),
                    "duration": DateFormat("yyyy").format(endDate),
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
          "${experienceItems[0]['title'] ?? ''} at ${experienceItems[0]['company'] ?? ''}";
    }
    if (educationItems.isNotEmpty) {
      if (combined.isNotEmpty) combined += "\n";
      combined +=
          "${educationItems[0]['degree'] ?? ''} from ${educationItems[0]['institution'] ?? ''}";
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
                            backgroundColor: Colors.white.withOpacity(0.55),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SetupProfileUploadPhoto(
                                  showProgress: false,
                                ),
                              ),
                            );
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
                                                      .platformDefault);
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
                        const Divider(),
                        buildEditableSection(
                          title: "ABOUT",
                          content: about,
                          isEditing: isEditingAbout,
                          controller: _aboutController,
                          field: "about",
                          onToggleEdit: () => _toggleEdit("about"),
                          onSave: () => _saveField("about"),
                        ),
                        const Divider(),
                        buildEditableSection(
                          title: "Past Experience",
                          content: pastExperience,
                          isEditing: isEditingPastExperience,
                          controller: _pastExperienceController,
                          field: "pastExperience",
                          onToggleEdit: () => _toggleEdit("pastExperience"),
                          onSave: () => _saveField("pastExperience"),
                        ),
                        const Divider(),
                        buildEditableSection(
                          title: "Future Plans",
                          content: futurePlans,
                          isEditing: isEditingFuturePlans,
                          controller: _futurePlansController,
                          field: "futurePlans",
                          onToggleEdit: () => _toggleEdit("futurePlans"),
                          onSave: () => _saveField("futurePlans"),
                        ),
                        const Divider(),
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
                        const Divider(),
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
                        const Divider(),
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
