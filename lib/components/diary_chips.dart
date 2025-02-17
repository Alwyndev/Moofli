import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DiaryChips extends StatefulWidget {
  final List<dynamic> diaryEntries;
  final ValueChanged<dynamic> onDelete; // Callback to update the UI
  final String token;

  const DiaryChips({
    Key? key,
    required this.diaryEntries,
    required this.onDelete,
    required this.token,
  }) : super(key: key);

  @override
  _DiaryChipsState createState() => _DiaryChipsState();
}

class _DiaryChipsState extends State<DiaryChips> {
  // Initially show 15 chips.
  int _visibleChipsCount = 15;

  Future<void> _deleteDiaryEntry(dynamic diaryEntry) async {
    final entryId = diaryEntry['_id'];
    final url =
        'http://93.127.172.217:2004/api/diary/entries/$entryId'; // Correct URI

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': widget.token},
      );
      if (response.statusCode == 200) {
        // Notify the parent widget to remove the deleted entry from the list.
        widget.onDelete(diaryEntry);
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
    // Colors for the chips.
    final List<Color> chipColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    // Reverse the list so the most recent entries appear first.
    final reversedEntries = widget.diaryEntries.reversed.toList();
    final visibleEntries = reversedEntries.take(_visibleChipsCount).toList();

    return Column(
      children: [
        // Build a Chip for each visible diary entry.
        ...visibleEntries.asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          final diaryEntry = entry.value;
          final chipColor = chipColors[index % chipColors.length];

          // Parse and format the date.
          DateTime date;
          try {
            date = DateTime.parse(diaryEntry['createdAt'] ?? '');
          } catch (e) {
            date = DateTime.now();
          }
          final formattedDate = DateFormat('MMM d').format(date);
          final formattedDay = DateFormat('EEE').format(date);

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Chip(
              backgroundColor: chipColor.withOpacity(0.25),
              onDeleted: () async {
                await _deleteDiaryEntry(diaryEntry);
              },
              deleteIcon: Icon(Icons.delete, color: chipColor),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display date information.
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
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: chipColor, width: 2),
              ),
            ),
          );
        }).toList(),

        // "Load more..." button if there are more entries.
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
