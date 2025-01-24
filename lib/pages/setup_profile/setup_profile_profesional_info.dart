import 'package:flutter/material.dart';
import 'package:moofli_app/components/nav_buttons.dart';

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

  // Function to validate if a year is a 4-digit number
  bool isValidYear(String input) {
    int? year = int.tryParse(input);
    return year != null && year >= 1000 && year <= 9999;
  }

  // Function to validate all year fields
  void validateYearFields() {
    setState(() {
      // Validate start year
      startYearError = isValidYear(startYearController.text)
          ? ''
          : 'Start year must be a valid 4-digit year';

      // Validate end year
      endYearError = isValidYear(endYearController.text)
          ? ''
          : 'End year must be a valid 4-digit year';

      // Validate job start year
      jobStartYearError = isValidYear(jobStartYearController.text)
          ? ''
          : 'Job start year must be a valid 4-digit year';

      // Validate job end year
      jobEndYearError = isValidYear(jobEndYearController.text)
          ? ''
          : 'Job end year must be a valid 4-digit year';
    });
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
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height: 20),

            // Subtitle
            Text(
              'Complete your',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 2),

            // Title
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            // SizedBox(height: 8),

            // Decorative Line
            Row(
              children: [
                // Filled Progress
                Expanded(
                  flex: (3 * 100 ~/ 5),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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

                // Remaining Progress
                Expanded(
                  flex: (2 * 100 ~/ 5), // Remaining 4/5
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(224, 217, 217, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'You are ', // Normal text
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 109, 108, 108),
                    fontWeight: FontWeight.normal,
                  ),
                  children: [
                    TextSpan(
                      text: '60%', // Bold percentage
                      style: TextStyle(
                        color: const Color.fromARGB(255, 90, 90, 90),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' there', // Normal text after percentage
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Professional Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 20),
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
                    child: Text(
                      'Student',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 16),
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
                    child: Text(
                      'Professional',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Student Fields
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
              SizedBox(height: 20),
              TextField(
                controller: degreeController,
                decoration: InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: fieldOfStudyController,
                decoration: InputDecoration(
                  labelText: 'Field of Study/Branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  SizedBox(width: 16),
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

            // Professional Fields
            if (isSelected[1]) ...[
              TextField(
                controller: jobTitleController,
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: jobDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  SizedBox(width: 16),
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
              prev: 'setup_profile_skills',
              next: '/setup_profile_photo',
            ),
          ],
        ),
      ),
    );
  }
}
