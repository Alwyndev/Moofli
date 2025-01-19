import 'package:flutter/material.dart';

class SetupProfile1 extends StatefulWidget {
  const SetupProfile1({super.key});

  @override
  State<SetupProfile1> createState() => _SetupProfile1State();
}

class _SetupProfile1State extends State<SetupProfile1> {
  List<bool> isSelected = [true, false, false];
  late String gender;
  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

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
                  flex: (0.2 * 100 ~/ 5), // First page, 0/6 progress
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
                  flex: (4 * 100 ~/ 5), // Remaining 5/6
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

            SizedBox(height: 20),
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
                      text: '0%', // Bold percentage
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
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            SizedBox(height: 25),
            TextField(
              controller: dobController,
              decoration: InputDecoration(
                hintText: 'dd-mm-yyyy',
                hintStyle: TextStyle(
                  fontSize: 20,
                ),
                labelText: 'DOB',
                labelStyle: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.w500,
                    fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gender',
                style: TextStyle(fontSize: 20),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                // Male Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 0); // Select Male
                      }
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
                        width:
                            isSelected[0] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Male',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

                // Female Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 1); // Select Female
                      }
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
                        width:
                            isSelected[1] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Female',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons

                // Rather Not Say Button
                InkWell(
                  onTap: () {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = (i == 2); // Select Rather Not Say
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected[2]
                            ? Colors.black
                            : Colors.grey, // Highlight border
                        width:
                            isSelected[2] ? 2.0 : 1.0, // Thicker for selected
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.transparent, // No background color
                    ),
                    child: Text(
                      'Rather Not Say',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black, // Keep text color static
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/setup_profile_contact_info');
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
