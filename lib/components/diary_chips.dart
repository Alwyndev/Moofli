import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:moofli_app/pages/diary_page_new.dart';

class DiaryChips extends StatefulWidget {
  final List<dynamic> diaryEntries;
  final VoidCallback onRefresh;
  final String token;

  const DiaryChips({
    Key? key,
    required this.diaryEntries,
    required this.onRefresh,
    required this.token,
  }) : super(key: key);

  @override
  _DiaryChipsState createState() => _DiaryChipsState();
}

class _DiaryChipsState extends State<DiaryChips> {
  int _visibleChipsCount = 15;

  Future<void> _deleteDiaryEntry(dynamic diaryEntry) async {
    final entryId = diaryEntry['_id'];
    final url = 'http://93.127.172.217:2004/api/diary/entries/$entryId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': widget.token},
      );
      if (response.statusCode == 200) {
        widget.onRefresh(); // Refresh homepage after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete entry.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> chipColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    final reversedEntries = widget.diaryEntries.reversed.toList();
    final visibleEntries = reversedEntries.take(_visibleChipsCount).toList();

    return Column(
      children: [
        ...visibleEntries.asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          final diaryEntry = entry.value;
          final chipColor = chipColors[index % chipColors.length];

          DateTime date;
          try {
            date = DateTime.parse(diaryEntry['createdAt'] ?? '');
          } catch (e) {
            date = DateTime.now();
          }
          final formattedDate = DateFormat('MMM d').format(date);
          final formattedDay = DateFormat('EEE').format(date);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryPageNew(
                    existingEntry: diaryEntry['content'], // Pass existing text
                    entryId: diaryEntry['_id'], // Pass entry ID for updating
                  ),
                ),
              ).then((value) {
                if (value == true)
                  widget.onRefresh(); // Refresh homepage after edit
              });
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Chip(
                backgroundColor: chipColor.withOpacity(0.25),
                onDeleted: () async {
                  await _deleteDiaryEntry(diaryEntry);
                },
                deleteIcon: Icon(Icons.delete, color: chipColor),
                label: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDay,
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8.0),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: chipColor, width: 2),
                ),
              ),
            ),
          );
        }).toList(),
        if (_visibleChipsCount < reversedEntries.length)
          TextButton(
            onPressed: () {
              setState(() {
                _visibleChipsCount += 15;
              });
            },
            child: const Text("Load more..."),
          ),
      ],
    );
  }
}
