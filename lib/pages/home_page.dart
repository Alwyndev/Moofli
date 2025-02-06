import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, String> savedEntries = {};
  Map<String, dynamic> userData = {};
  String profilePic = "";
  String bgPic = "";

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
    _loadUserData();
  }

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
      print('User data not found in SharedPreferences');
    }
  }

  Future<void> _fetchProfile(String? token) async {
    if (token == null) {
      return;
    }
    print(token);
    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2004/api/user/profile/me'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null) {
          setState(() {
            profilePic = responseData['result']['profilePicUrl'] ?? "";
            bgPic = responseData['result']['bgPicUrl'] ?? "";
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _loadSavedEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.getKeys().where((key) => key.startsWith('diary_')).forEach((key) {
        savedEntries[key] = prefs.getString(key) ?? '';
      });
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2004/api/user/logout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['result'] == true) {
          await prefs.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? "Logged out successfully")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Logout failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'An error occurred. Please check your internet connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset('assets/images/logo.png', height: 80),
            Spacer(),
            SizedBox(width: 25),
            Icon(Icons.local_fire_department, color: Colors.black),
            Text('3', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData.isNotEmpty)
              UserAccountsDrawerHeader(
                accountName: Text(userData['firstname'] ?? ''),
                accountEmail: Text(userData['email'] ?? ''),
                currentAccountPicture: userData['profilePic'] != null
                    ? CircleAvatar(backgroundImage: NetworkImage(profilePic))
                    : CircleAvatar(backgroundImage: NetworkImage(profilePic)),
              )
            else
              const UserAccountsDrawerHeader(
                accountName: Text('Loading...'),
                accountEmail: Text(''),
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title:
                  Text('Logout Account', style: TextStyle(color: Colors.red)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          ...savedEntries.entries.map((entry) {
            DateTime entryDate =
                DateTime.parse(entry.key.replaceFirst('diary_', ''));
            String formattedDate = DateFormat('dd MMMM yyyy').format(entryDate);
            String previewText = entry.value.split('\n').first;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(formattedDate),
                subtitle: Text(previewText),
                onTap: () {
                  // Navigate to a detailed view of the entry
                },
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/diary_entry_new');
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Color.fromRGBO(0, 119, 255, 0.6),
        splashColor: Colors.blue,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(profilePic),
            ),
            label: '',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, "/home");
          } else if (index == 1) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
