import 'package:flutter/material.dart';

class TimelinePage extends StatefulWidget {
  final String timelineId;
  const TimelinePage({Key? key, required this.timelineId}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.timelineId),
    );
  }
}
