import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'login_page.dart';
// import 'diary_page_new.dart';
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
  // Calendar states
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Scroll controller to listen for scroll events to adjust the calendar view
  late ScrollController _scrollController;

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

    // Initialize scroll controller and add a listener
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load user data and diary entries from the API
    _loadUserData();
    _fetchDiaryEntries();
  }

  @override
  void dispose() {
    // Remove the scroll listener and dispose of the controller
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener that adjusts the calendar view (month/week)
  /// based on the vertical scroll offset.
  void _onScroll() {
    if (_scrollController.offset > 50 &&
        _calendarFormat != CalendarFormat.week) {
      setState(() {
        _calendarFormat = CalendarFormat.week;
      });
    } else if (_scrollController.offset <= 50 &&
        _calendarFormat != CalendarFormat.month) {
      setState(() {
        _calendarFormat = CalendarFormat.month;
      });
    }
  }

  /// Loads user details stored in SharedPreferences, then fetches
  /// additional profile information from the API.
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
  /// Expects a response containing keys such as profilePicUrl, bgPicUrl, and streak.
  Future<void> _fetchProfile(String? token) async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2024/api/user/profile/me'),
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
  /// The API response is expected to contain a key "entries" with a list of entries.
  Future<void> _fetchDiaryEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2024/api/diary/entries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

  /// Builds a Wrap widget containing a Chip for each diary entry.
  /// Each Chip displays the content of the diary entry.

  Widget _buildDiaryEntryChips() {
    // Define the list of colors you want to use.
    final List<Color> chipColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    // Reverse the diary entries list.
    final reversedEntries = _diaryEntries.reversed.toList();

    return Column(
      children: reversedEntries.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        final diaryEntry = entry.value;
        // Cycle through the colors using the modulo operator.
        final chipColor = chipColors[index % chipColors.length];

        // Parse and format the date.
        DateTime date;
        try {
          // Adjust parsing as needed if your API uses a custom format.
          date = DateTime.parse(diaryEntry['createdAt'] ?? '');
        } catch (e) {
          // Fallback if parsing fails.
          date = DateTime.now();
        }
        final formattedDate = DateFormat('MMM d').format(date);
        final formattedDay = DateFormat('EEEE').format(date);
        final abbreviatedDay = formattedDay.substring(0, 3);

        return Container(
          width: double.infinity, // Forces the chip to stretch full width.
          margin: const EdgeInsets.only(bottom: 8.0), // Adds vertical spacing.
          child: Chip(
            backgroundColor: chipColor.withOpacity(0.25),
            label: Align(
              alignment: Alignment.centerLeft, // Left-aligns the content.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use a Column to display the formatted date above the day.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        abbreviatedDay,
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(
                      width:
                          8.0), // Spacing between date info and diary content.
                  Expanded(
                    child: Text(
                      diaryEntry['content'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: chipColor, width: 2),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Logs the user out by clearing the SharedPreferences and
  /// navigating back to the login page.
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      if (kDebugMode) {
        print('No token found');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No token found. Please log in again.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://93.127.172.217:2024/api/user/logout'),
      );
      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['result'] == true) {
          await prefs.setBool('isLoggedIn', false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? "Logged out successfully")),
          );
          await prefs.clear();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Logout failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Logout failed. Please try again later.')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('An error occurred. Please check your internet connection.'),
        ),
      );
    }
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
            // App logo image
            Image.asset('assets/images/logo.png', height: 80),
            const Spacer(),
            const SizedBox(width: 25),
            // Flame icon with gradient effect to show the user's streak
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
            // Display the streak number with a similar gradient effect
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
            // Profile and Settings navigation
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
            // Logout option
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
        controller: _scrollController,
        children: [
          // TableCalendar widget with dynamic format (month/week)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          // Section label for diary entries
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Diary Entries:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Display the diary entries as Chips using a Wrap widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDiaryEntryChips(),
          ),
          const SizedBox(height: 16),
        ],
      ),
      // Floating action button to add a new diary entry
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the diary entry creation page and refresh entries on return
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
