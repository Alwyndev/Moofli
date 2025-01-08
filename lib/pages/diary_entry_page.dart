import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DiaryEntryPage extends StatefulWidget {
  const DiaryEntryPage({super.key});

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Opens the sidebar
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
            SizedBox(width: 8),
            Spacer(),
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            Spacer(),
            Icon(Icons.local_fire_department, color: Colors.black),
            SizedBox(width: 4),
            Text('3', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('France Leaphart'),
              accountEmail: Text('10 Friends'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150', // Replace with your image URL
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                // Handle Profile navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle Settings navigation
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Handle Logout
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 24,
                  color: Color.fromRGBO(1, 35, 153, 1),
                ),
                maxLines: null, // Allows the TextField to grow vertically
                expands:
                    true, // Makes the TextField fill the available vertical space
                decoration: InputDecoration(
                  fillColor: Color.fromRGBO(103, 136, 254, 1),
                  filled: true,
                  hintText: "Enter text here...",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(1, 35, 153, 1),
                  ),
                  iconColor: Colors.blue,
                  contentPadding: EdgeInsets.only(
                    top: 12.0,
                    left: 12.0,
                  ), // Align hint text to top-left
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // Curved borders
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2.0), // Border when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0), // Border when not focused
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  // Action for image icon
                },
                child: FaIcon(FontAwesomeIcons.image,
                    size: 24, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // Action for bold icon
                },
                child:
                    FaIcon(FontAwesomeIcons.bold, size: 24, color: Colors.blue),
              ),
              GestureDetector(
                onTap: () {
                  // Action for italic icon
                },
                child: FaIcon(FontAwesomeIcons.italic,
                    size: 24, color: Colors.green),
              ),
              GestureDetector(
                onTap: () {
                  // Action for underline icon
                },
                child: FaIcon(FontAwesomeIcons.underline,
                    size: 24, color: Colors.red),
              ),
              GestureDetector(
                onTap: () {
                  // Action for 't' icon
                },
                child:
                    FaIcon(FontAwesomeIcons.t, size: 24, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // Action for justify align icon
                },
                child: FaIcon(FontAwesomeIcons.alignJustify,
                    size: 24, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // Action for left align icon
                },
                child: FaIcon(FontAwesomeIcons.alignLeft,
                    size: 24, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // Action for center align icon
                },
                child: FaIcon(FontAwesomeIcons.alignCenter,
                    size: 24, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  // Action for right align icon
                },
                child: FaIcon(FontAwesomeIcons.alignRight,
                    size: 24, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
