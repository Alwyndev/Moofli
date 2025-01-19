import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isBold = false;
bool isItalic = false;
bool isUnderline = false;
bool isStrikethrough = false;
TextAlign alignment = TextAlign.left;

TextStyle getTextStyle() {
  return TextStyle(
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    decoration: TextDecoration.combine([
      if (isUnderline) TextDecoration.underline,
      if (isStrikethrough) TextDecoration.lineThrough,
    ]),
  );
}

void toggleBold(Function updateState) {
  isBold = !isBold;
  updateState(); // Calls setState() in the parent widget
}

void toggleItalic(Function updateState) {
  isItalic = !isItalic;
  updateState();
}

void toggleUnderline(Function updateState) {
  isUnderline = !isUnderline;
  updateState();
}

void toggleStrikethrough(Function updateState) {
  isStrikethrough = !isStrikethrough;
  updateState();
}

void setAlignment(TextAlign align, Function updateState) {
  alignment = align;
  updateState();
}

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
