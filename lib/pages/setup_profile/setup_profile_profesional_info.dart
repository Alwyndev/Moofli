import 'package:flutter/material.dart';

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
            SizedBox(height: 100),

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
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Align buttons to the left
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
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[0]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width: isSelected[0]
                            ? 2.0
                            : 1.0, // Slightly thicker when selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color change
                    ),
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

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
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[1]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width: isSelected[1]
                            ? 2.0
                            : 1.0, // Slightly thicker when selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color change
                    ),
                    child: Text(
                      'Professional',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Phone Number
            const SizedBox(height: 20),
            TextField(
              controller: collegeController,
              decoration: InputDecoration(
                labelText: 'College/Institution',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: degreeController,
              decoration: InputDecoration(
                labelText: 'Degree',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: fieldOfStudyController,
              decoration: InputDecoration(
                labelText: 'Field of Study/Branch',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
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
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endYearController,
                    decoration: InputDecoration(
                      labelText: 'End Year',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              controller: jobTitleController,
              decoration: InputDecoration(
                labelText: 'Job Title',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(
                labelText: 'Company Name',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: jobDescriptionController,
              decoration: InputDecoration(
                labelText: 'Job Description',
                labelStyle: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jobStartYearController,
                    decoration: InputDecoration(
                      labelText: 'Start Year',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18, // Adjusted font size for better fit
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Adds space between the TextFields
                Expanded(
                  child: TextField(
                    controller: jobEndYearController,
                    decoration: InputDecoration(
                      labelText: 'End Year',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18, // Adjusted font size for better fit
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Spreads the buttons apart
                children: [
                  // Back Button (Circular)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/setup_profile_skills',
                      );
                    }, // Add your onTap logic here
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child:
                          Icon(Icons.arrow_back, size: 24, color: Colors.black),
                    ),
                  ),

                  // Next Button (Rounded Rectangle)
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/setup_profile_photo',
                      );
                    }, // Add your onTap logic here
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "NEXT",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8), // Space between text and icon
                          Icon(Icons.arrow_forward,
                              size: 24, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
