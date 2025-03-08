import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moofli_app/components/diary_chips.dart';
import 'package:moofli_app/pages/diary_page_new.dart';
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

  /// Returns a list of diary entries for a given day based on the "createdAt" field.
  List<dynamic> _getEventsForDay(DateTime day) {
    return _diaryEntries.where((entry) {
      if (entry['createdAt'] == null) return false;
      try {
        DateTime entryDate = DateTime.parse(entry['createdAt']);
        return isSameDay(entryDate, day);
      } catch (e) {
        if (kDebugMode) print('Error parsing createdAt: $e');
        return false;
      }
    }).toList();
  }

  /// Refreshes the whole page by clearing any selected date,
  /// resetting the focused day to today, and reloading user data and diary entries.
  Future<void> _refreshPage() async {
    setState(() {
      _selectedDay = null;
      _focusedDay = DateTime.now();
    });
    await _loadUserData();
    await _fetchDiaryEntries();
  }

  /// Loads user details from SharedPreferences and fetches additional profile info.
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
      if (kDebugMode) print('User data not found in SharedPreferences');
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
        if (kDebugMode)
          print("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching profile: $e');
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
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _diaryEntries = responseData['entries'] ?? [];
        });
        if (kDebugMode) print("Diary entries loaded: $_diaryEntries");
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch diary entries. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching diary entries: $e');
    }
  }

  /// Logs the user out.
  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userDetails');
      await prefs.setBool('isLoggedIn', false);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  /// Toggles the calendar view between week and month.
  void _toggleCalendarFormat() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  // Handle horizontal swipe to navigate to the profile page.
  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter diary entries based on the selected day.
    List<dynamic> filteredEntries = _selectedDay != null
        ? _diaryEntries.where((entry) {
            if (entry['createdAt'] == null) return false;
            try {
              DateTime entryDate = DateTime.parse(entry['createdAt']);
              return isSameDay(entryDate, _selectedDay!);
            } catch (e) {
              if (kDebugMode) print('Error parsing createdAt: $e');
              return false;
            }
          }).toList()
        : _diaryEntries;

    String headerText = _selectedDay != null
        ? 'Diary Entries on ${_selectedDay!.toLocal().toString().split(' ')[0]}'
        : 'All Diary Entries';

    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalSwipe,
      child: Scaffold(
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
          // Removed the refresh icon button from the actions
        ),
        drawer: Drawer(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userData.isNotEmpty)
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(bgPic),
                        fit: BoxFit.cover,
                      ),
                    ),
                    accountName: Text(
                      userData['firstname'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    accountEmail: Text(
                      userData['email'] ?? '',
                      style: const TextStyle(color: Colors.black),
                    ),
                    currentAccountPicture: userData['profilePic'] != null
                        ? const CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/default_profile_pic.png'),
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
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => logout(context),
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: ListView(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleCalendarFormat,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          MaterialLocalizations.of(context)
                              .formatMonthYear(_focusedDay),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCalendar(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      headerVisible: false,
                      calendarFormat: _isCalendarExpanded
                          ? CalendarFormat.month
                          : CalendarFormat.week,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          return const SizedBox();
                        },
                        defaultBuilder: (context, date, _) {
                          if (_getEventsForDay(date).isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/fire_background.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                          return null;
                        },
                        todayBuilder: (context, date, _) {
                          if (_getEventsForDay(date).isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/fire_background.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        selectedBuilder: (context, date, _) {
                          if (_getEventsForDay(date).isNotEmpty) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/fire_background.png',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        if (kDebugMode) {
                          print("New selected day: $_selectedDay");
                        }
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  headerText,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final token = snapshot.data?.getString('token') ?? '';
                      return DiaryChips(
                        diaryEntries: filteredEntries,
                        token: token,
                        onRefresh: _fetchDiaryEntries,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiaryPageNew()),
            ).then((result) {
              if (result == true) {
                _fetchDiaryEntries();
              }
            });
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          backgroundColor: const Color.fromRGBO(0, 119, 255, 0.6),
          splashColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
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
              if (ModalRoute.of(context)?.settings.name != "/home") {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home",
                  (Route<dynamic> route) => false,
                );
              }
            } else if (index == 1) {
              if (ModalRoute.of(context)?.settings.name != "/profile") {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/profile',
                  (Route<dynamic> route) => false,
                );
              }
            }
          },
        ),
      ),
    );
  }
}
