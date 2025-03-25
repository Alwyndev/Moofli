import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';
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
    if (isSelected[0]) {
      await prefs.setString('Profession', 'Student');
    } else if (isSelected[1]) {
      await prefs.setString('Profession', 'Professional');
    }

    // Save other professional info locally.
    await prefs.setString('College', collegeController.text);
    await prefs.setString('Degree', degreeController.text);
    await prefs.setString('fieldOfStudy', fieldOfStudyController.text);
    await prefs.setString('startCollege', startYearController.text);
    await prefs.setString('endCollege', endYearController.text);

    if (isSelected[1]) {
      await prefs.setString('JobTitle', jobTitleController.text);
      await prefs.setString('Company', companyNameController.text);
      await prefs.setString('Description', jobDescriptionController.text);
      await prefs.setString('startJob', jobStartYearController.text);
      await prefs.setString('endJob', jobEndYearController.text);
    }

    // Update backend with professional info.
    Map<String, dynamic> result = await ApiService.updateMultipleProfileFields({
      'Profession': isSelected[0] ? 'Student' : 'Professional',
      'College': collegeController.text,
      'Degree': degreeController.text,
      'fieldOfStudy': fieldOfStudyController.text,
      'startCollege': startYearController.text,
      'endCollege': endYearController.text,
      // Include job details if Professional.
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
          const SnackBar(content: Text("Failed to update professional info")));
    }
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
            const SizedBox(height: 20),
            const Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: (3 * 100 ~/ 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  flex: (2 * 100 ~/ 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(224, 217, 217, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: RichText(
                text: const TextSpan(
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
            const SizedBox(height: 20),
            const Text(
              'Professional Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isSelected[0] = true;
                      isSelected[1] = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[0] ? Colors.black : Colors.grey,
                        width: isSelected[0] ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Text(
                      'Student',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSelected[0] = false;
                      isSelected[1] = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[1] ? Colors.black : Colors.grey,
                        width: isSelected[1] ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Text(
                      'Professional',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                        errorText:
                            endYearError.isNotEmpty ? endYearError : null,
                      ),
                      onChanged: (_) => validateYearFields(),
                    ),
                  ),
                ],
              ),
            ],
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
                        errorText:
                            endYearError.isNotEmpty ? endYearError : null,
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
            ],
            const SizedBox(height: 20),
            NavButtons(
                prev: '/setup_profile_contact_info', next: saveProfessionalInfo)
          ],
        ),
      ),
    );
  }
}
