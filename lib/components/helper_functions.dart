import 'package:flutter/material.dart';

/// Converts a given [text] to Title Case.
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() +
        (word.length > 1 ? word.substring(1).toLowerCase() : '');
  }).join(' ');
}

/// A widget that initially displays [initialLines] (default 3) of [text].
/// If the text overflows, a “Read more” option appears which increases
/// the number of displayed lines by 15 when tapped.
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int initialLines;
  const ExpandableTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.initialLines = 3,
  }) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late int _currentMaxLines;
  @override
  void initState() {
    super.initState();
    _currentMaxLines = widget.initialLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final textSpan = TextSpan(text: widget.text, style: widget.style);
      final tp = TextPainter(
        text: textSpan,
        maxLines: _currentMaxLines,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: constraints.maxWidth);
      final didOverflow = tp.didExceedMaxLines;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: widget.style,
            maxLines: _currentMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          if (didOverflow)
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentMaxLines += 15;
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "Read more",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Builds an editable section widget. When not in editing mode, if the [content]
/// is empty a message is shown. For fields such as "about" and "futurePlans",
/// the content is wrapped in an [ExpandableTextWidget].
Widget buildEditableSection({
  required String title,
  required String content,
  required bool isEditing,
  required TextEditingController controller,
  required String field,
  required VoidCallback onToggleEdit,
  required VoidCallback onSave,
}) {
  Widget displayWidget;
  if (!isEditing) {
    if (content.trim().isEmpty) {
      displayWidget = Text(
        "No information provided for $title.",
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      );
    } else if (field == "about" || field == "futurePlans") {
      displayWidget = ExpandableTextWidget(
        text: content,
        style: const TextStyle(fontSize: 14),
      );
    } else {
      displayWidget = Text(content, style: const TextStyle(fontSize: 14));
    }
  } else {
    displayWidget = TextField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(hintText: "Enter $title"),
    );
  }
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit, size: 16),
              onPressed: isEditing ? onSave : onToggleEdit,
            ),
          ],
        ),
        const SizedBox(height: 4),
        displayWidget,
      ],
    ),
  );
}

/// Builds a widget for a single experience item. When in edit mode, an edit
/// icon is shown that opens the edit dialog.
Widget buildExperienceItem({
  required int index,
  required String title,
  required String company,
  required String duration,
  required VoidCallback onDelete,
  required bool isEditing,
  VoidCallback? onEdit,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(company,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(duration,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        if (isEditing) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ],
    ),
  );
}

/// Builds the complete Experience section.
Widget buildExperienceSection({
  required bool isEditingExperience,
  required List<Map<String, String>> experienceItems,
  required VoidCallback onToggleEdit,
  required VoidCallback onAddExperience,
  required Function(int) onDeleteExperience,
  required Function(int) onEditExperience,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon:
                  Icon(isEditingExperience ? Icons.save : Icons.edit, size: 16),
              onPressed: onToggleEdit,
            ),
            if (isEditingExperience)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue, size: 16),
                onPressed: onAddExperience,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(experienceItems.length, (index) {
            return buildExperienceItem(
              index: index,
              title: experienceItems[index]["title"] ?? "",
              company: experienceItems[index]["company"] ?? "",
              duration: experienceItems[index]["duration"] ?? "",
              onDelete: () => onDeleteExperience(index),
              isEditing: isEditingExperience,
              onEdit: () => onEditExperience(index),
            );
          }),
        ),
      ],
    ),
  );
}

/// Builds a skill chip widget.
Widget buildSkillChip({
  required String label,
  required Color color,
  VoidCallback? onDeleted,
}) {
  return Chip(
    backgroundColor: color.withOpacity(0.15),
    onDeleted: onDeleted,
    label: Text(label, style: const TextStyle(color: Colors.black)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: color, width: 2),
    ),
  );
}

/// Builds the complete Skills section.
Widget buildSkillsSection({
  required bool isEditingSkills,
  required List<String> skills,
  required VoidCallback onToggleEdit,
  required VoidCallback onAddSkill,
  required Function(int) onDeleteSkill,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("SKILLS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isEditingSkills ? Icons.save : Icons.edit, size: 16),
              onPressed: onToggleEdit,
            ),
            if (isEditingSkills)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue, size: 16),
                onPressed: onAddSkill,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(skills.length, (index) {
            return buildSkillChip(
              label: skills[index],
              color: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
              ][index % 5],
              onDeleted: isEditingSkills ? () => onDeleteSkill(index) : null,
            );
          }),
        ),
      ],
    ),
  );
}

/// Builds the complete Education section.
Widget buildEducationSection({
  required bool isEditingEducation,
  required List<Map<String, String>> educationItems,
  required VoidCallback onToggleEdit,
  required VoidCallback onAddEducation,
  required Function(int) onDeleteEducation,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Education",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon:
                  Icon(isEditingEducation ? Icons.save : Icons.edit, size: 16),
              onPressed: onToggleEdit,
            ),
            if (isEditingEducation)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue, size: 16),
                onPressed: onAddEducation,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(educationItems.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(educationItems[index]["degree"] ?? "",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(educationItems[index]["institution"] ?? "",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                        Text(educationItems[index]["duration"] ?? "",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (isEditingEducation)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDeleteEducation(index),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    ),
  );
}
