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
    // TODO: implement build
    throw UnimplementedError();
  }
}
