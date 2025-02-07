import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryChips extends StatefulWidget {
  final List<dynamic> diaryEntries;

  const DiaryChips({Key? key, required this.diaryEntries}) : super(key: key);

  @override
  _DiaryChipsState createState() => _DiaryChipsState();
}

class _DiaryChipsState extends State<DiaryChips> {
  // Initially show 15 chips.
  int _visibleChipsCount = 15;

  @override
  Widget build(BuildContext context) {
    // Define the list of colors you want to use.
    final List<Color> chipColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    // Reverse the diary entries list so that the most recent ones come first.
    final reversedEntries = widget.diaryEntries.reversed.toList();
    // Take only the first _visibleChipsCount items.
    final visibleEntries = reversedEntries.take(_visibleChipsCount).toList();

    return Column(
      children: [
        // Map visible diary entries to chips.
        ...visibleEntries.asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          final diaryEntry = entry.value;
          // Cycle through the colors using the modulo operator.
          final chipColor = chipColors[index % chipColors.length];

          // Parse and format the date.
          DateTime date;
          try {
            date = DateTime.parse(diaryEntry['createdAt'] ?? '');
          } catch (e) {
            // Fallback in case parsing fails.
            date = DateTime.now();
          }
          final formattedDate = DateFormat('MMM d').format(date);
          // Use 'EEE' for abbreviated day names (e.g., "Mon", "Tue").
          final formattedDay = DateFormat('EEE').format(date);

          return Container(
            width: double.infinity, // Makes the chip stretch the full width.
            margin:
                const EdgeInsets.only(bottom: 8.0), // Adds vertical spacing.
            child: Chip(
              backgroundColor: chipColor.withOpacity(0.25),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display the formatted date and abbreviated day.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDay,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        width: 8.0), // Spacing between date info and content.
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

        // If there are more entries than are currently visible, show the "Load more..." button.
        if (_visibleChipsCount < reversedEntries.length)
          TextButton(
            onPressed: () {
              setState(() {
                _visibleChipsCount += 15; // Load 15 more entries.
              });
            },
            child: const Text("Load more..."),
          ),
      ],
    );
  }
}
