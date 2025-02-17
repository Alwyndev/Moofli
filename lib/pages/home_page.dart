import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moofli_app/components/diary_chips.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Calendar states
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Control whether the calendar is expanded (month view) or compact (week view)
  bool _isCalendarExpanded = false;

  // User and profile data variables
  Map<String, dynamic> userData = {};
  String profilePic = "";
  String bgPic = "";
  String streak = "";

  // List to hold diary entries fetched from the API
  List<dynamic> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDiaryEntries();
  }

  /// Loads user details stored in SharedPreferences, then fetches additional profile information from the API.
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userDetails');
    String? token = prefs.getString('token');

    if (userDataJson != null) {
      setState(() {
        userData = json.decode(userDataJson);
        userData['token'] = token;
      });
      await _fetchProfile(token);
    } else {
      if (kDebugMode) {
        print('User data not found in SharedPreferences');
      }
    }
  }

  /// Fetches the user profile details from the API.
  Future<void> _fetchProfile(String? token) async {
    if (token == null) return;

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
            streak = (responseData['result']['streak'] ?? 0).toString();
          });
        }
      } else {
        if (kDebugMode) {
          print("Failed to fetch profile: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
    }
  }

  /// Fetches diary entries from the API.
  Future<void> _fetchDiaryEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2004/api/diary/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _diaryEntries = responseData['entries'] ?? [];
        });
        if (kDebugMode) {
          print("Diary entries loaded: $_diaryEntries");
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch diary entries. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching diary entries: $e');
      }
    }
  }

  /// Logs the user out by calling the API endpoint.
  Future<void> logout(BuildContext context) async {
    final url = Uri.parse('http://93.127.172.217:2004/api/user/logout');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  /// Toggles the calendar view between week (compact) and month (expanded).
  void _toggleCalendarFormat() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with logo and streak display
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset('assets/images/logo.png', height: 80),
            const Spacer(),
            const SizedBox(width: 25),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: streak == '0'
                    ? [Colors.black, Colors.black]
                    : [Colors.yellow, Colors.deepOrange],
              ).createShader(bounds),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: streak == '0'
                    ? [Colors.black, Colors.black]
                    : [Colors.yellow, Colors.deepOrange],
              ).createShader(bounds),
              child: Text(
                streak,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      // Navigation drawer with profile information and settings
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData.isNotEmpty)
              UserAccountsDrawerHeader(
                accountName: Text(userData['firstname'] ?? ''),
                accountEmail: Text(userData['email'] ?? ''),
                currentAccountPicture: userData['profilePic'] != null
                    ? const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/default_profile_pic.png'),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(profilePic),
                      ),
              )
            else
              const UserAccountsDrawerHeader(
                accountName: Text('Loading...'),
                accountEmail: Text(''),
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout Account',
                  style: TextStyle(color: Colors.red)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      // Main body: ListView containing the calendar and diary entry chips
      body: ListView(
        children: [
          // Custom header above the calendar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Custom header that shows the month and toggles the calendar view when tapped.
                GestureDetector(
                  onTap: _toggleCalendarFormat,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      MaterialLocalizations.of(context)
                          .formatMonthYear(_focusedDay),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // The TableCalendar with its built-in header hidden.
                TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  headerVisible: false, // Hides the default header.
                  calendarFormat: _isCalendarExpanded
                      ? CalendarFormat.month
                      : CalendarFormat.week,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  // Update the focused day when the calendar is swiped.
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Diary Entries:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DiaryChips(diaryEntries: _diaryEntries),
          ),
          const SizedBox(height: 16),
        ],
      ),
      // Floating action button to add a new diary entry
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/diary_entry_new')
              .then((_) => _fetchDiaryEntries());
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: const Color.fromRGBO(0, 119, 255, 0.6),
        splashColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      // Bottom navigation bar with Home and Profile options
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: profilePic.isNotEmpty
                  ? NetworkImage(profilePic)
                  : const AssetImage('assets/images/default_profile_pic.png')
                      as ImageProvider,
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
