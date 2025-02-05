import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryPageNew extends StatefulWidget {
  const DiaryPageNew({super.key});

  @override
  State<DiaryPageNew> createState() => _DiaryPageNewState();
}

class _DiaryPageNewState extends State<DiaryPageNew> {
  TextEditingController dairyEntryController = TextEditingController();

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;
  TextAlign alignment = TextAlign.left;

  final List<IconData> toolbarIcons = [
    Icons.format_bold,
    Icons.format_italic,
    Icons.format_underline,
    Icons.format_strikethrough,
    Icons.format_align_left,
    Icons.format_align_center,
    Icons.format_align_right,
    Icons.format_align_justify,
    Icons.copy,
    Icons.paste,
    // Icons.save,
  ];

  void updateState() => setState(() {});

  void setAlignment(TextAlign align) {
    alignment = align;
    updateState();
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: dairyEntryController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied to clipboard")),
    );
  }

  void pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      dairyEntryController.text += data.text!;
      updateState();
    }
  }

  void saveEntry() async {
    String textToSave = dairyEntryController.text;
    if (textToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No text to save")),
      );
      return;
    }

    // Save the text to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key =
        DateTime.now().toString(); // Use the current date and time as the key
    await prefs.setString(key, textToSave);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Entry saved successfully")),
    );
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
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    decoration: TextDecoration.combine([
                      if (isUnderline) TextDecoration.underline,
                      if (isStrikethrough) TextDecoration.lineThrough,
                    ]),
                  ),
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
          saveEntry();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Color.fromRGBO(0, 119, 255, 0.6),
        child: Icon(Icons.save_outlined, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        items: toolbarIcons.map((icon) {
          return BottomNavigationBarItem(
            icon: Icon(icon, color: Colors.black, size: 30),
            label: '',
          );
        }).toList(),
        currentIndex: 0,
        onTap: (index) {
          switch (toolbarIcons[index]) {
            case Icons.format_bold:
              setState(() => isBold = !isBold);
              break;
            case Icons.format_italic:
              setState(() => isItalic = !isItalic);
              break;
            case Icons.format_underline:
              setState(() => isUnderline = !isUnderline);
              break;
            case Icons.format_strikethrough:
              setState(() => isStrikethrough = !isStrikethrough);
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
              copyToClipboard();
              break;
            case Icons.paste:
              pasteFromClipboard();
              break;
            default:
              print("Pressed ${toolbarIcons[index]}");
          }
        },
      ),
    );
  }
}
