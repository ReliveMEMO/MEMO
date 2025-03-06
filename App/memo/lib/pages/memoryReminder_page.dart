import 'package:flutter/material.dart';

class MemoryReminderPopup extends StatelessWidget {
  const MemoryReminderPopup({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch arguments safely
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments is Map<String, dynamic> ? arguments : {};
    VoidCallback onClose = args['onClose'] ??
        () {
          Navigator.of(context).pop();
        };

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

        // Close Button
        Positioned(
          right: 20,
          top: 40,
          child: GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
