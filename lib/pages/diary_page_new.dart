import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryPageNew extends StatefulWidget {
  final String? existingEntry;
  final String? entryId; // To determine if it's an update

  const DiaryPageNew({super.key, this.existingEntry, this.entryId});

  @override
  State<DiaryPageNew> createState() => _DiaryPageNewState();
}

class _DiaryPageNewState extends State<DiaryPageNew> {
  // Renamed for clarity
  TextEditingController diaryEntryController = TextEditingController();
  late SharedPreferences prefs;
  String? token;

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
  ];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();

    // Load existing diary entry if available
    if (widget.existingEntry != null) {
      diaryEntryController.text = widget.existingEntry!;
    }
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  void setAlignment(TextAlign align) {
    setState(() {
      alignment = align;
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: diaryEntryController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard")),
    );
  }

  void pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      setState(() {
        diaryEntryController.text += data.text!;
      });
    }
  }

  void saveEntry() async {
    String textToSave = diaryEntryController.text;
    if (textToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No text to save")),
      );
      return;
    }

    Map<String, dynamic> data = {"content": textToSave};
    String body = json.encode(data);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '$token',
    };

    try {
      final Uri apiUrl;
      final bool isUpdating = widget.entryId != null;

      if (isUpdating) {
        apiUrl = Uri.parse(
            'https://skillop.in/api/diary/dairyupdate/${widget.entryId}');
      } else {
        apiUrl = Uri.parse('https://skillop.in/api/diary/dairyCreate');
      }

      final response = await (isUpdating
          ? http.put(apiUrl, headers: headers, body: body)
          : http.post(apiUrl, headers: headers, body: body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isUpdating
                ? "Entry updated successfully!"
                : "Entry saved successfully!"),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        );
        Navigator.pop(context, true); // Indicate that a refresh is needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM').format(now);
    String formattedDay = DateFormat('EEEE').format(now);
    String formattedYear = now.year.toString();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Refresh homepage on back press
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedDate.toUpperCase(),
                  style: const TextStyle(color: Colors.green, fontSize: 16)),
              Text("$formattedYear, $formattedDay",
                  style: const TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                color: Color.fromRGBO(145, 185, 56, 0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: diaryEntryController,
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
                    decoration: const InputDecoration(
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
          onPressed: saveEntry,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          backgroundColor: const Color.fromRGBO(34, 72, 79, 0.75),
          child: const Icon(Icons.save_outlined, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
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
              case Icons.format_align_justify:
                setAlignment(TextAlign.justify);
                break;
              case Icons.copy:
                copyToClipboard();
                break;
              case Icons.paste:
                pasteFromClipboard();
                break;
              default:
                debugPrint("Pressed ${toolbarIcons[index]}");
            }
          },
        ),
      ),
    );
  }
}
