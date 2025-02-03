import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  ];

  void updateState() => setState(() {});

  void setAlignment(
      TextAlign align, Function updateState, TextAlign alignment) {
    alignment = align;
    updateState();
  } // Generic state update function

  void copyToClipboard(TextEditingController controller, BuildContext context) {
    Clipboard.setData(ClipboardData(text: controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied to clipboard")),
    );
  }

  void pasteFromClipboard(
      TextEditingController controller, Function updateState) async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      controller.text += data.text!;
      updateState();
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
          Navigator.pushNamed(context, '/dairy_entry_new');
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Color.fromRGBO(0, 119, 255, 0.6),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        items: [
          ...toolbarIcons.map((icon) => BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    setState(() {
                      switch (icon) {
                        case Icons.format_bold:
                          // toggleBold(updateState, isBold);
                          isBold = !isBold;
                          break;
                        case Icons.format_italic:
                          // toggleItalic(updateState, isItalic);
                          isItalic = !isItalic;
                          break;
                        case Icons.format_underline:
                          // toggleUnderline(updateState, isUnderline);
                          isUnderline = !isUnderline;
                          break;
                        case Icons.format_strikethrough:
                          // toggleStrikethrough(updateState, isStrikethrough);
                          isStrikethrough = !isStrikethrough;
                          break;
                        case Icons.format_align_left:
                          setAlignment(TextAlign.left, updateState, alignment);
                          alignment = TextAlign.left;
                          break;
                        case Icons.format_align_center:
                          setAlignment(
                              TextAlign.center, updateState, alignment);
                          alignment = TextAlign.center;
                          break;
                        case Icons.format_align_right:
                          setAlignment(TextAlign.right, updateState, alignment);
                          alignment = TextAlign.right;
                          break;
                        case Icons.copy:
                          copyToClipboard(dairyEntryController, context);
                          break;
                        case Icons.paste:
                          pasteFromClipboard(
                              dairyEntryController, () => setState(() {}));
                          break;
                        default:
                          print("Pressed $icon");
                      }
                    });
                  },
                  child: Icon(
                    icon,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                label: '',
              ))
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
