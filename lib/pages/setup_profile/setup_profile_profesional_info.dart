import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
import 'package:moofli_app/components/progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_services.dart';

class SetupProfileProfesionalInfo extends StatefulWidget {
  const SetupProfileProfesionalInfo({super.key});

  @override
  State<SetupProfileProfesionalInfo> createState() =>
      _SetupProfileProfesionalInfoState();
}

class _SetupProfileProfesionalInfoState
    extends State<SetupProfileProfesionalInfo> {
  double progressPercentage = 0.4;
  List<bool> isSelected = [true, false];

  // TextEditingControllers
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController fieldOfStudyController = TextEditingController();
  final TextEditingController startYearController = TextEditingController();
  final TextEditingController endYearController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController jobStartYearController = TextEditingController();
  final TextEditingController jobEndYearController = TextEditingController();

  // Error messages for year fields
  String startYearError = '';
  String endYearError = '';
  String jobStartYearError = '';
  String jobEndYearError = '';

  bool isValidYear(String input) {
    int? year = int.tryParse(input);
    return year != null && year >= 1000 && year <= 9999;
  }

  void validateYearFields() {
    setState(() {
      startYearError = isValidYear(startYearController.text)
          ? ''
          : 'Start year must be a valid 4-digit year';
      endYearError = isValidYear(endYearController.text)
          ? ''
          : 'End year must be a valid 4-digit year';
      jobStartYearError = isValidYear(jobStartYearController.text)
          ? ''
          : 'Job start year must be a valid 4-digit year';
      jobEndYearError = isValidYear(jobEndYearController.text)
          ? ''
          : 'Job end year must be a valid 4-digit year';
    });
  }

  Future<void> saveProfessionalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the profession
    if (isSelected[0]) {
      await prefs.setString('Profession', 'Student');
    } else if (isSelected[1]) {
      await prefs.setString('Profession', 'Professional');
    }

    // Save other professional info locally
    await prefs.setString('College', collegeController.text);
    await prefs.setString('Degree', degreeController.text);
    await prefs.setString('fieldOfStudy', fieldOfStudyController.text);
    await prefs.setString('startCollege', startYearController.text);
    await prefs.setString('endCollege', endYearController.text);

    // If Professional is selected, save job info
    if (isSelected[1]) {
      await prefs.setString('JobTitle', jobTitleController.text);
      await prefs.setString('Company', companyNameController.text);
      await prefs.setString('Description', jobDescriptionController.text);
      await prefs.setString('startJob', jobStartYearController.text);
      await prefs.setString('endJob', jobEndYearController.text);
    }

    // Update backend with professional info
    Map<String, dynamic> result = await ApiService.updateMultipleProfileFields({
      'Profession': isSelected[0] ? 'Student' : 'Professional',
      'College': collegeController.text,
      'Degree': degreeController.text,
      'fieldOfStudy': fieldOfStudyController.text,
      'startCollege': startYearController.text,
      'endCollege': endYearController.text,
      // Include job details if Professional
      if (isSelected[1]) ...{
        'JobTitle': jobTitleController.text,
        'Company': companyNameController.text,
        'Description': jobDescriptionController.text,
        'startJob': jobStartYearController.text,
        'endJob': jobEndYearController.text,
      }
    });

    if (result['success']) {
      Navigator.pushNamed(context, '/setup_profile_skills');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update professional info")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the main content as a ListView
    Widget bodyContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          // Progress bar
          ProgressBar(progress: progressPercentage),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Toggle for Student / Professional with icons, darker border, and transparent background when selected
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Student Button
              InkWell(
                onTap: () {
                  setState(() {
                    isSelected[0] = true;
                    isSelected[1] = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected[0]
                        ? const Color.fromRGBO(24, 100, 108, 1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected[0]
                          ? const Color.fromRGBO(24, 100, 108, 1.0)
                          : Colors.grey,
                      width: isSelected[0] ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: isSelected[0] ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected[0] ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Professional Button
              InkWell(
                onTap: () {
                  setState(() {
                    isSelected[0] = false;
                    isSelected[1] = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected[1]
                        ? const Color.fromRGBO(144, 185, 40, 1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected[1]
                          ? const Color.fromRGBO(144, 185, 40, 1)
                          : Colors.grey,
                      width: isSelected[1] ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.work,
                        color: isSelected[1] ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Professional',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected[1] ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fields for Student
          if (isSelected[0]) ...[
            TextField(
              controller: collegeController,
              decoration: InputDecoration(
                labelText: 'College/Institution',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: degreeController,
              decoration: InputDecoration(
                labelText: 'Degree',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: fieldOfStudyController,
              decoration: InputDecoration(
                labelText: 'Field of Study/Branch',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startYearController,
                    decoration: InputDecoration(
                      labelText: 'Start Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText:
                          startYearError.isNotEmpty ? startYearError : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endYearController,
                    decoration: InputDecoration(
                      labelText: 'End Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: endYearError.isNotEmpty ? endYearError : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
              ],
            ),
          ],

          // Fields for Professional
          if (isSelected[1]) ...[
            TextField(
              controller: collegeController,
              decoration: InputDecoration(
                labelText: 'College/Institution',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: degreeController,
              decoration: InputDecoration(
                labelText: 'Degree',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fieldOfStudyController,
              decoration: InputDecoration(
                labelText: 'Field of Study/Branch',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startYearController,
                    decoration: InputDecoration(
                      labelText: 'Start Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText:
                          startYearError.isNotEmpty ? startYearError : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endYearController,
                    decoration: InputDecoration(
                      labelText: 'End Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: endYearError.isNotEmpty ? endYearError : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: jobTitleController,
              decoration: InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: jobDescriptionController,
              decoration: InputDecoration(
                labelText: 'Job Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jobStartYearController,
                    decoration: InputDecoration(
                      labelText: 'Job Start Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText: jobStartYearError.isNotEmpty
                          ? jobStartYearError
                          : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: jobEndYearController,
                    decoration: InputDecoration(
                      labelText: 'Job End Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      errorText:
                          jobEndYearError.isNotEmpty ? jobEndYearError : null,
                    ),
                    onChanged: (_) => validateYearFields(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // NavButtons remain inside the ListView if "Professional" is selected
            NavButtons(
              prev: '/setup_profile_contact_info',
              next: saveProfessionalInfo,
            ),
          ],

          // Extra spacing at the end
          const SizedBox(height: 20),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      // If Student is selected, place NavButtons at the bottom
      bottomNavigationBar: isSelected[0]
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: NavButtons(
                prev: '/setup_profile_contact_info',
                next: saveProfessionalInfo,
              ),
            )
          : null,
      body: bodyContent,
    );
  }
}
