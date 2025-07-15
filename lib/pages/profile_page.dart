// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moofli_app/auth_providers.dart';
import 'package:moofli_app/components/helper_functions.dart';
// import 'package:moofli_app/pages/setup_profile/setup_profile_upload_photo.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import '../api/api_services.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // Editing flags for each section
  bool isEditingBio = false;
  bool isEditingLinkedIn = false;
  bool isEditingAbout = false;
  bool isEditingPastExperience = false;
  bool isEditingFuturePlans = false;
  bool isEditingExperience = false;
  bool isEditingSkills = false;
  bool isEditingEducation = false;

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

  Future<void> _refreshProfile() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.getUserProfile();
  }

  void _toggleEdit(String field) {
    setState(() {
      final userData = ref.read(authProvider).userDetails;
      switch (field) {
        case 'about':
          isEditingAbout = !isEditingAbout;
          if (isEditingAbout) _aboutController.text = userData?['about'] ?? '';
          break;
        case 'pastExperience':
          isEditingPastExperience = !isEditingPastExperience;
          if (isEditingPastExperience) {
            _pastExperienceController.text = userData?['pastExp'] ?? '';
          }
          break;
        case 'futurePlans':
          isEditingFuturePlans = !isEditingFuturePlans;
          if (isEditingFuturePlans) {
            _futurePlansController.text = userData?['futurePlans'] ?? '';
          }
          break;
        case 'bio':
          isEditingBio = !isEditingBio;
          if (isEditingBio) _bioController.text = userData?['about'] ?? '';
          break;
      }
    });
  }

  Future<void> _saveField(String field) async {
    final authNotifier = ref.read(authProvider.notifier);
    final token = ref.read(authProvider).token;
    String newValue = '';

    setState(() {
      switch (field) {
        case 'about':
          newValue = _aboutController.text;
          isEditingAbout = false;
          break;
        case 'pastExperience':
          newValue = _pastExperienceController.text;
          isEditingPastExperience = false;
          break;
        case 'futurePlans':
          newValue = _futurePlansController.text;
          isEditingFuturePlans = false;
          break;
        case 'bio':
          newValue = _bioController.text;
          isEditingBio = false;
          break;
      }
    });

    final success = await ApiService.updateProfileField(token, field, newValue);
    if (success) {
      await _refreshProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $field')),
      );
    }
  }

  Future<void> _updateExperienceInBackend(
      List<Map<String, dynamic>> items) async {
    final token = ref.read(authProvider).token;
    final success = await ApiService.updateMultipleProfileFields(
        token, {'experence': items});
    if (success != null) {
      await _refreshProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update experience')),
      );
    }
  }

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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                              } else {
                                endDateController.clear();
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
                      if (kDebugMode) print("Error formatting duration: $e");
                    }

                    final newExpItem = {
                      "title": titleController.text.trim(),
                      "company": companyController.text.trim(),
                      "startDate": isoStart,
                      "endDate": isoEnd,
                      "location": "",
                      "description": "",
                      "_id": UniqueKey().toString(),
                      "duration": duration,
                    };

                    final userData = ref.read(authProvider).userDetails;
                    final currentExperiences = List<Map<String, dynamic>>.from(
                        userData?['experence'] ?? []);
                    currentExperiences.add(newExpItem);

                    await _updateExperienceInBackend(currentExperiences);
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

  Future<void> _pickAndUploadPhoto(String type) async {
    final token = ref.read(authProvider).token;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    if (pickedFile == null) return;

    final uploadSuccess =
        await ApiService.uploadPhoto(token, pickedFile.path, type);
    if (uploadSuccess) {
      await _refreshProfile();
    }
  }

  String _combinedBio(Map<String, dynamic>? userData) {
    if (userData == null) return '';

    String combined = "";
    final experiences = userData['experence'] as List<dynamic>? ?? [];
    if (experiences.isNotEmpty) {
      combined +=
          "${experiences[0]['title'] ?? ''} at ${experiences[0]['company'] ?? ''}";
    }

    final education = userData['education'] as List<dynamic>? ?? [];
    if (education.isNotEmpty) {
      if (combined.isNotEmpty) combined += "\n";
      combined +=
          "${education[0]['degree'] ?? ''} from ${education[0]['institution'] ?? ''}";
    }
    return combined;
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userData = authState.userDetails;

    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final DateFormat dateFormat = DateFormat("MMM yyyy", "en_US");

    // Process experience data
    final experienceItems =
        (userData['experence'] as List<dynamic>? ?? []).map((item) {
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

    // Process education data
    final educationItems =
        (userData['education'] as List<dynamic>? ?? []).map((item) {
      String endDate = item["endDate"] ?? "";
      String duration = "";
      try {
        DateTime date = DateTime.parse(endDate);
        duration = DateFormat("yyyy").format(date);
      } catch (e) {
        duration = endDate;
      }
      return {
        "degree": item["degree"] ?? "",
        "institution": item["institution"] ?? "",
        "endDate": endDate,
        "fieldOfStudy": item["fieldOfStudy"] ?? "",
        "duration": duration,
        "_id": item["_id"] ?? ""
      };
    }).toList();

    // Process skills data
    final skills = (userData['skills'] as List<dynamic>? ?? [])
        .map((skill) {
          return toTitleCase(skill.toString().trim());
        })
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
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
                      image: userData['bgPicUrl']?.isNotEmpty == true
                          ? NetworkImage(userData['bgPicUrl'])
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
                      backgroundColor: Colors.white.withOpacity(0.55),
                    ),
                    onPressed: () {
                      _pickAndUploadPhoto('background');
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
                        backgroundImage:
                            userData['profilePicUrl']?.isNotEmpty == true
                                ? NetworkImage(userData['profilePicUrl'])
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
                              '${userData['firstname'] ?? ''} ${userData['lastname'] ?? ''}',
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
                                              hintText: "Enter your bio"),
                                        )
                                      : (_combinedBio(userData).trim().isEmpty
                                          ? const Text("No bio provided.",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic))
                                          : Text(_combinedBio(userData),
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
                            : (userData['linkedinId']?.trim().isEmpty == true
                                ? const Text("No LinkedIn URL provided.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic))
                                : InkWell(
                                    onTap: () async {
                                      final uri =
                                          Uri.parse(userData['linkedinId']);
                                      if (await url_launcher
                                          .canLaunchUrl(uri)) {
                                        await url_launcher.launchUrl(uri,
                                            mode: url_launcher
                                                .LaunchMode.platformDefault);
                                      }
                                    },
                                    child: Text(userData['linkedinId'],
                                        style: TextStyle(
                                            color: Colors.blue.shade800,
                                            decoration:
                                                TextDecoration.underline)),
                                  )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  buildEditableSection(
                    title: "ABOUT",
                    content: userData['about'] ?? '',
                    isEditing: isEditingAbout,
                    controller: _aboutController,
                    field: "about",
                    onToggleEdit: () => _toggleEdit("about"),
                    onSave: () => _saveField("about"),
                  ),
                  const Divider(),
                  buildEditableSection(
                    title: "Past Experience",
                    content: userData['pastExp'] ?? '',
                    isEditing: isEditingPastExperience,
                    controller: _pastExperienceController,
                    field: "pastExperience",
                    onToggleEdit: () => _toggleEdit("pastExperience"),
                    onSave: () => _saveField("pastExperience"),
                  ),
                  const Divider(),
                  buildEditableSection(
                    title: "Future Plans",
                    content: userData['futurePlans'] ?? '',
                    isEditing: isEditingFuturePlans,
                    controller: _futurePlansController,
                    field: "futurePlans",
                    onToggleEdit: () => _toggleEdit("futurePlans"),
                    onSave: () => _saveField("futurePlans"),
                  ),
                  const Divider(),
                  buildExperienceSection(
                    isEditingExperience: isEditingExperience,
                    experienceItems: experienceItems
                        .map((item) => item.map((key, value) =>
                            MapEntry(key, value?.toString() ?? "")))
                        .toList(),
                    onToggleEdit: () {
                      setState(() {
                        isEditingExperience = !isEditingExperience;
                      });
                    },
                    onAddExperience: _addExperience,
                    onDeleteExperience: (index) async {
                      final id = experienceItems[index]["_id"] ?? "";
                      if (id.isNotEmpty) {
                        final token = ref.read(authProvider).token;
                        final success =
                            await ApiService.deleteExperience(token, id);
                        if (success) {
                          await _refreshProfile();
                        }
                      }
                    },
                    onEditExperience: (index) =>
                        _editExperience(index, experienceItems),
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
                    onAddSkill: () async {
                      final skillController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Add Skill"),
                            content: TextField(
                              controller: skillController,
                              decoration:
                                  const InputDecoration(hintText: "Skill Name"),
                              textCapitalization: TextCapitalization.words,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final token = ref.read(authProvider).token;
                                  final success = await ApiService.addSkill(
                                      token, skillController.text);
                                  if (success) {
                                    await _refreshProfile();
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDeleteSkill: (index) async {
                      final token = ref.read(authProvider).token;
                      final success =
                          await ApiService.deleteSkill(token, skills[index]);
                      if (success) {
                        await _refreshProfile();
                      }
                    },
                  ),
                  const Divider(),
                  buildEducationSection(
                    isEditingEducation: isEditingEducation,
                    educationItems: educationItems
                        .map((item) => item.map((key, value) =>
                            MapEntry(key, value?.toString() ?? "")))
                        .toList(),
                    onToggleEdit: () {
                      setState(() {
                        isEditingEducation = !isEditingEducation;
                      });
                    },
                    onAddEducation: () async {
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
                                    decoration: const InputDecoration(
                                        hintText: "Degree"),
                                  ),
                                  TextField(
                                    controller: institutionController,
                                    decoration: const InputDecoration(
                                        hintText: "Institution"),
                                  ),
                                  TextField(
                                    controller: endYearController,
                                    decoration: const InputDecoration(
                                        hintText: "End Year (e.g., 2020)"),
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
                                  final token = ref.read(authProvider).token;
                                  final newEdu = {
                                    "degree": degreeController.text.trim(),
                                    "institution":
                                        institutionController.text.trim(),
                                    "endDate": DateTime(
                                            int.parse(
                                                endYearController.text.trim()),
                                            1,
                                            1)
                                        .toIso8601String(),
                                  };
                                  final success = await ApiService.addEducation(
                                      token, newEdu);
                                  if (success) {
                                    await _refreshProfile();
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDeleteEducation: (index) async {
                      final id = educationItems[index]["_id"] ?? "";
                      if (id.isNotEmpty) {
                        final token = ref.read(authProvider).token;
                        final success = await ApiService.deleteEducation(
                            token, id, "education");
                        if (success) {
                          await _refreshProfile();
                        }
                      }
                    },
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
              backgroundImage: userData['profilePicUrl']?.isNotEmpty == true
                  ? NetworkImage(userData['profilePicUrl'])
                  : const AssetImage('assets/images/default_profile_pic.png')
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
    );
  }

  Future<void> _editExperience(
      int index, List<Map<String, dynamic>> experienceItems) async {
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
      if (kDebugMode) print("Error parsing startDate: $e");
    }

    bool isCurrent =
        experienceItems[index]["endDate"]?.toLowerCase() == "present";
    if (!isCurrent) {
      try {
        endDate = DateTime.parse(experienceItems[index]["endDate"]!);
        endDateController.text = inputFormat.format(endDate);
      } catch (e) {
        if (kDebugMode) print("Error parsing endDate: $e");
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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                              } else {
                                endDateController.clear();
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
                      if (kDebugMode)
                        print("Error formatting duration during edit: $e");
                    }

                    final updatedItem = {
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

                    final userData = ref.read(authProvider).userDetails;
                    final currentExperiences = List<Map<String, dynamic>>.from(
                        userData?['experence'] ?? []);
                    currentExperiences[index] = updatedItem;

                    await _updateExperienceInBackend(currentExperiences);
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
}

// Helper widgets (buildEditableSection, buildExperienceSection, etc.) would be defined here
// They would be similar to the ones in your original code but adapted to use the Riverpod state
