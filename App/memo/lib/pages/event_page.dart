import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isAttending = false; // Track attendance
  int attendeeCount = 12; // Initial attendee count
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Event Name & Club Name
            const Text(
              "Sky Light",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://media.vanityfair.com/photos/5f5245d91e10df7a77868af6/master/w_2560%2Cc_limit/avatar-the-last-airbender.jpg'), // club logo
                ),
                const SizedBox(width: 5),
                const Text(
                  "@RACCM",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Event Image
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC7C5C5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8), // Padding inside the box
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://media.vanityfair.com/photos/5f5245d91e10df7a77868af6/master/w_2560%2Cc_limit/avatar-the-last-airbender.jpg',
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Event Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoBox("FEBRUARY 28"),
                const SizedBox(width: 10),
                _infoBox("7:00PM ONWARDS"),
              ],
            ),
            const SizedBox(height: 15),

            // Event Description Box
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Join us for Sky Light, teerrtteterwrwrw ",
                style: TextStyle(fontSize: 14, color: Color(0xDD000000)),
              ),
            ),
            const SizedBox(height: 20),

            // Attending Button
            GestureDetector(
              onTap: () {
                setState(() {
                  isAttending = !isAttending;
                  isAttending ? attendeeCount++ : attendeeCount--;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isAttending
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF7f31c6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  isAttending ? "ATTENDING ✔ " : "ATTENDING",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            //Attendees Section

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6SGvshARHJ5GYSH_Kig8-cYNw5rO3nWn7mA&s'), // club logo
                ),
                const SizedBox(
                  width: 4,
                ),
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6SGvshARHJ5GYSH_Kig8-cYNw5rO3nWn7mA&s'), // club logo
                ),
                const SizedBox(
                  width: 4,
                ),
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6SGvshARHJ5GYSH_Kig8-cYNw5rO3nWn7mA&s'), // club logo
                ),
                
                const SizedBox(width: 5),
                Text("$attendeeCount Attending",
                 style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Info Boxes (Date, Time)
  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

