import 'package:flutter/material.dart';

class DiaryPageNew extends StatefulWidget {
  const DiaryPageNew({super.key});

  @override
  State<DiaryPageNew> createState() => _DiaryPageNewState();
}

class _DiaryPageNewState extends State<DiaryPageNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "19 JANUARY",
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            Text(
              "2025, Sunday",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  20, // Number of icons
                  (index) => Icon(
                    Icons.widgets,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Card(
              margin: EdgeInsets.all(16),
              color: Colors.blue[300],
              child: Center(
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
            icon: Icon(Icons.home, color: Colors.black, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            label: '',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
