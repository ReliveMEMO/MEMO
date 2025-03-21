import 'package:flutter/material.dart';

class MemoryReminderPage extends StatelessWidget {
  final String imageUrl;
  final String date;
  final String memoryText;
  final String heading;
  final List<String> collaborators;
  final VoidCallback onClose;

  const MemoryReminderPage({
    super.key,
    required this.imageUrl,
    required this.date,
    required this.memoryText,
    required this.heading,
    required this.collaborators,
    required this.onClose,
    required String postImage,
    required String memoryDate,
    required String postHeading,
    required List collaboratorAvatars,
    required List collaboratorNames,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Transparent Background
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ],
    );
  }
}
