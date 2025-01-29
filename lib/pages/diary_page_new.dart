import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextAlign alignment = TextAlign.left;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  // Map to track selected icons
  Map<IconData, bool> iconStates = {
    for (var icon in toolbarIcons) icon: false,
  };

  TextStyle getTextStyle() {
    return TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  void copyToClipboard(TextEditingController controller, BuildContext context) {
    final text = controller.text;
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void pasteFromClipboard(
      TextEditingController controller, VoidCallback callback) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      controller.text = data.text!;
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM').format(now);
    String formattedDay = DateFormat('EEEE').format(now);
    String formattedYear = now.year.toString();

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
                          setState(() {
                            iconStates[icon] = !iconStates[icon]!;
                            switch (icon) {
                              case Icons.format_bold:
                                isBold = !isBold;
                                break;
                              case Icons.format_italic:
                                isItalic = !isItalic;
                                break;
                              case Icons.format_underline:
                                isUnderline = !isUnderline;
                                break;
                              case Icons.format_strikethrough:
                                // Handle strikethrough
                                break;
                              case Icons.format_align_left:
                                setAlignment(TextAlign.left);
                                break;
                              case Icons.format_align_center:
                                setAlignment(TextAlign.center);
                                break;
                              case Icons.format_align_right:
                                setAlignment(TextAlign.right);
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
                  maxLines: null,
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

  void setAlignment(TextAlign align) {
    setState(() {
      alignment = align;
    });
  }
}
