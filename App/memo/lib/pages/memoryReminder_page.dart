import 'package:flutter/material.dart';

class MemoryReminderPopup extends StatelessWidget {
  const MemoryReminderPopup({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch arguments safely
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments is Map<String, dynamic>
        ? arguments
        : {
            'imageUrl': "https://via.placeholder.com/300",
            'date': "March 6, 2025",
            'memoryText': "Memo Meeting!",
            'collaborators': [
              "https://via.placeholder.com/"
              
            ],
            'onClose': () {
              Navigator.of(context).pop();
            },
          };

    String imageUrl = args['imageUrl'] ?? '';
    String date = args['date'] ?? '';
    String memoryHeading = args['memoryText'] ?? '';
    List<String> collaborators = List<String>.from(args['collaborators'] ?? []);
    VoidCallback onClose = args['onClose'] ?? () {
      Navigator.of(context).pop();
    };

    return Stack(
      children: [
        // Transparent Background
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.9),
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

        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "#ThrowBacks",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: const Color.fromARGB(255, 208, 207, 207),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    imageUrl,
                    width: 300,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Remember that day",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                date,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                memoryHeading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 70),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: collaborators
                    .map((avatar) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(avatar),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 5),

              Text(
                collaborators.isNotEmpty
                    ? collaborators.map((c) => "@$c").join(", ") + " were with you!"
                    : "no collaborators",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
