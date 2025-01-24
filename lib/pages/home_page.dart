import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime get _firstDayOfMonth {
    return DateTime(_focusedDay.year, _focusedDay.month, 1);
  }

  // int get _today {
  //   return DateTime.now().day;
  // }

  DateTime get _yesterday {
    return DateTime.now().subtract(Duration(days: 1));
  }

  // int get _dayBeforeYesterday {
  //   return DateTime.now().subtract(Duration(days: 2)).day;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Builder(
            //   builder: (context) {
            //     return GestureDetector(
            //       onTap: () {
            //         Scaffold.of(context).openDrawer();
            //       },
            //       child: CircleAvatar(
            //         backgroundImage: AssetImage('assets/images/logo.png'),
            //       ),
            //     );
            //   },
            // ),
            SizedBox(width: 8),
            Spacer(),
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
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
            UserAccountsDrawerHeader(
              accountName: Text('France Leaphart'),
              accountEmail: Text('10 Friends'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            color: Colors.white,
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
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                ),
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                rangeStartDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                defaultDecoration: BoxDecoration(
                  color: _focusedDay.isAfter(_firstDayOfMonth) &&
                          _focusedDay.isBefore(_yesterday)
                      ? Colors.green
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dairy_entry_new');
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Color.fromRGBO(0, 119, 255, 0.6),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/home");
              },
              child: Icon(Icons.home, color: Colors.black, size: 40),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                // Add desired functionality for the second icon tap here
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
            ),
            label: '',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle tap for BottomNavigationBar if needed
        },
      ),
    );
  }
}
