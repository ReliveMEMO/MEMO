import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isAttending = false; // Track attendance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // title: const Text(
        //   "Event Details",
        //   style: TextStyle(color: Colors.black, fontSize: 16),
        // ),
        //centerTitle: false,
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
              "Spandana 3.0",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                      "https://example.com/user_profile.jpg"), // club logo
                ),
                const SizedBox(width: 5),
                const Text(
                  "@Leo_IIT",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "image.jpg",
                width: MediaQuery.of(context).size.width * 0.7, 
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

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
              width: 300, 
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Join us for Spandana 3.0 ,spandanaaaaaaaaaaaaaa ",
                style: TextStyle(fontSize: 14, color: Color(0xDD000000)),
              ),
            ),
            const SizedBox(height: 20),

            // Attending Button
            GestureDetector(
              onTap: () {
                setState(() {
                  isAttending = !isAttending;
                });
              },
              child: Container(
                width: 300, 
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isAttending ? const Color(0xFF9E9E9E) : const Color(0xFF7f31c6),
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

            // Attendees Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/attending_icon.png", width: 20), // Replace with actual asset
                const SizedBox(width: 5),
                const Text("Attending", style: TextStyle(color: Colors.grey)),
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



// class EventPage extends StatefulWidget {
//   final String eventName;
//   final String clubName;
//   final String eventImage;
//   final String eventDate;
//   final String eventTime;
//   final String eventDescription;

//   const EventPage({
//     Key? key,
//     required this.eventName,
//     required this.clubName,
//     required this.eventImage,
//     required this.eventDate,
//     required this.eventTime,
//     required this.eventDescription,
//   }) : super(key: key);

//   @override
//   _EventPageState createState() => _EventPageState();
// }

// class _EventPageState extends State<EventPage> {
//   bool isAttending = false;

//   void toggleAttendance() {
//     setState(() {
//       isAttending = !isAttending;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Event Details", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Event Image
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   widget.eventImage,
//                   height: 250,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),

//             // Date & Time
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                       vertical: 12, horizontal: 16), // Increase padding
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     widget.eventDate,
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500), // Bigger text
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                       vertical: 12, horizontal: 16), // Increase padding
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     widget.eventTime,
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500), // Bigger text
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 16),

//             // Event Description
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 widget.eventDescription,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             // Attending Button
//             ElevatedButton(
//               onPressed: toggleAttendance,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isAttending
//                     ? const Color(0xFF9C27B0)
//                     : const Color(0xFF601B74),
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: Text(
//                 isAttending ? "ATTENDING ✅" : "ATTENDING",
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//             SizedBox(height: 10),

//             // Attendance Status
//             if (isAttending)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.people, color: Colors.purple),
//                   SizedBox(width: 5),
//                   Text(
//                     "You are attending",
//                     style: TextStyle(color: Colors.purple, fontSize: 16),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

