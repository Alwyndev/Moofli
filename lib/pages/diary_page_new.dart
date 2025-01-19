import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moofli_app/components/icon_helpers.dart';
import 'package:moofli_app/components/icons_list.dart';

class DiaryPageNew extends StatefulWidget {
  const DiaryPageNew({super.key});

  @override
  State<DiaryPageNew> createState() => _DiaryPageNewState();
}

class _DiaryPageNewState extends State<DiaryPageNew> {
  TextEditingController dairyEntryController = TextEditingController();

  // Map to track selected icons
  Map<IconData, bool> iconStates = {
    for (var icon in toolbarIcons) icon: false,
  };

  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime now = DateTime.now();

    // Format the date
    String formattedDate = DateFormat('dd MMMM').format(now); // date and month
    String formattedDay = DateFormat('EEEE').format(now); // day
    String formattedYear = now.year.toString(); // year

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate.toUpperCase(),
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            Text(
              "$formattedYear, $formattedDay",
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
                children: toolbarIcons
                    .map(
                      (icon) => GestureDetector(
                        onTap: () {
                          // Update the state of the selected icon
                          setState(() {
                            iconStates[icon] = !iconStates[icon]!;

                            // Perform icon-specific actions
                            switch (icon) {
                              case Icons.format_bold:
                                toggleBold(() => setState(() {}));
                                break;
                              case Icons.format_italic:
                                toggleItalic(() => setState(() {}));
                                break;
                              case Icons.format_underline:
                                toggleUnderline(() => setState(() {}));
                                break;
                              case Icons.format_strikethrough:
                                toggleStrikethrough(() => setState(() {}));
                                break;
                              case Icons.format_align_left:
                                setAlignment(
                                    TextAlign.left, () => setState(() {}));
                                break;
                              case Icons.format_align_center:
                                setAlignment(
                                    TextAlign.center, () => setState(() {}));
                                break;
                              case Icons.format_align_right:
                                setAlignment(
                                    TextAlign.right, () => setState(() {}));
                                break;
                              case Icons.copy:
                                copyToClipboard(dairyEntryController, context);
                                break;
                              case Icons.paste:
                                pasteFromClipboard(dairyEntryController,
                                    () => setState(() {}));
                                break;
                              default:
                                print("Pressed $icon");
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: iconStates[icon]!
                                ? Colors.grey[300]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(icon, size: 30),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              color: Colors.blue[300],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: dairyEntryController,
                  maxLines: null, // Allows multiple lines
                  textAlign: alignment,
                  style: getTextStyle(),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle, color: Colors.purple),
            label: '',
          ),
        ],
      ),
    );
  }
}
