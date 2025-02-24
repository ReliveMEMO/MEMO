import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  final String eventImage;
  final String eventDate;
  final String eventTime;
  final String eventDescription;

  const EventPage({
    Key? key,
    required this.eventImage,
    required this.eventDate,
    required this.eventTime,
    required this.eventDescription,
  }) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isAttending = false;

  void toggleAttendance() {
    setState(() {
      isAttending = !isAttending;
    });
  }
  
  

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.eventImage,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(widget.eventDate),
                  backgroundColor: Colors.grey[100],
                ),
                SizedBox(width: 10),
                Chip(
                  label: Text(widget.eventTime),
                  backgroundColor: Colors.grey[100],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Event Description
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.eventDescription,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            // Attending Button
            ElevatedButton(
              onPressed: toggleAttendance,
              style: ElevatedButton.styleFrom(
                 backgroundColor: isAttending ? Colors.purple : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isAttending ? "ATTENDING ✅" : "ATTENDING",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),

            // Attendance Status
            if (isAttending)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, color: Colors.purple),
                  SizedBox(width: 5),
                  Text(
                    "You are attending",
                    style: TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}