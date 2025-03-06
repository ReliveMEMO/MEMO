import 'package:flutter/material.dart';

class MemoryReminderPopup extends StatelessWidget {
  const MemoryReminderPopup({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch arguments safely
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final args = arguments is Map<String, dynamic> ? arguments : {
      'imageUrl': "https://via.placeholder.com/300"
    };
    VoidCallback onClose = args['onClose'] ??
        () {
          Navigator.of(context).pop();
        };

    String imageUrl = args['imageUrl'] ?? '';    

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
        
          // Main Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "#ThrowBacks",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),

              //image box
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    imageUrl,
                    width: 300,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Remember that day",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),  
        ),  

      ],
    );
    
  }
}
