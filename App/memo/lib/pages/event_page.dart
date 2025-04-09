import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/pages/create_event.dart';
import 'package:memo/providers/backend.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EventPage extends StatefulWidget {
  final String eventId;
  const EventPage({super.key, required this.eventId});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isAttending = false; // Track attendance
  String attendeeCount = ""; // Initial attendee count
  bool isLoading = false; // Loading state
  PostgrestMap? eventDetails; // Event details
  PostgrestMap? pageDetails;
  List<String> avatarPaths = [];
  List<String> avatars = [];

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('id', widget.eventId);

    if (!mounted) return;

    final pageResponse = await Supabase.instance.client
        .from('page_table')
        .select()
        .eq('id', response[0]['admin']);

    setState(() {
      eventDetails = response[0];
      pageDetails = pageResponse[0];
    });

    print(eventDetails);
    getUsers();

    setState(() {
      isAttending =
          eventDetails?["attendance"].contains(authService.getCurrentUserID());

      isLoading = false;
    });
  }

  void updateEventAttendance() async {
    // Get the current attendance array
    List<dynamic> currentAttendance = eventDetails?["attendance"] ?? [];
    final userId = authService.getCurrentUserID();

    // Check if the user is already in the attendance list
    if (currentAttendance.contains(userId)) {
      // If the user is already attending, remove them
      currentAttendance.remove(userId);
    } else {
      // Otherwise, add the user to the attendance list
      currentAttendance.add(userId);
      await sendNotificationToFollowed();
    }

    // Update the attendance array in the database
    final response = await Supabase.instance.client
        .from('events')
        .update({'attendance': currentAttendance}).eq('id', widget.eventId);

    if (response != null) {
      print("Error updating attendance: ${response.error?.message}");
    } else {
      // Update the local state
      setState(() {
        eventDetails?["attendance"] = currentAttendance;
        attendeeCount = currentAttendance.length < 1000
            ? currentAttendance.length.toString()
            : "1k+";
        isAttending = currentAttendance.contains(userId);
      });
    }
  }

  void getUsers() async {
    if (eventDetails?["attendance"] != null) {
      List<dynamic> firstThreeCollaborators =
          eventDetails?["attendance"].take(3).toList();

      List<String> fetchedAvatarPaths = [];
      for (var collaboratorId in firstThreeCollaborators) {
        final avatarResponse = await Supabase.instance.client
            .from('User_Info')
            .select('profile_pic')
            .eq('id', collaboratorId)
            .single();

        if (avatarResponse != null) {
          fetchedAvatarPaths.add(avatarResponse['profile_pic']);
        }
      }

      if (!mounted) return;

      setState(() {
        avatars = fetchedAvatarPaths;
      });
    }

    setState(() {
      attendeeCount = eventDetails?["attendance"]?.length.toString() ?? "0";
    });
  }

  Future<void> sendNotificationToFollowed() async {
    final backendUrl = Backend.backendUrl;
    final url = Uri.parse(
        '$backendUrl/api/send-notification-to-followed'); // Replace with your API URL

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender_id': authService.getCurrentUserID(),
        'notification_type': "Event",
        'message': "going to ${eventDetails?["event_name"]}",
        "eventId": widget.eventId,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully: ${response.body}');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        toolbarHeight: 40, //reduce Appbar height
      ),
      body: isLoading
          ? Skeletonizer(child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Event Name & Club Name
                  Text(
                    eventDetails?["event_name"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: CachedNetworkImageProvider(
                            pageDetails?["image_url"]), // club logo
                      ),
                      const SizedBox(width: 5),
                      Text(
                        pageDetails?["page_name"],
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event Image
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 241, 239, 239),
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
                        imageUrl: eventDetails?["cover"],
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
                      _infoBox(
                        eventDetails?["Date"] != null
                            ? DateTime.parse(eventDetails?["Date"])
                                .toLocal()
                                .toString()
                                .split(' ')[0] // Extract only the date portion
                            : "No Date",
                      ),
                      const SizedBox(width: 10),
                      _infoBox(
                        eventDetails?["Date"] != null
                            ? "${DateTime.parse(eventDetails?["Date"]).toLocal().toString().split(' ')[1].substring(0, 5)} Onwards" // Extract only the time portion (HH:mm)
                            : "No Time",
                      ),
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
                    child: Text(
                      eventDetails?["caption"],
                      style: TextStyle(fontSize: 14, color: Color(0xDD000000)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Attending Button
                  GestureDetector(
                    onTap: () {
                      updateEventAttendance();
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
                        isAttending ? "ATTENDING" : "WILL ATTEND",
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
                      ...avatars.map((avatarUrl) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  CachedNetworkImageProvider(avatarUrl),
                            ),
                          )),
                      const SizedBox(width: 5),
                      Text(
                        "$attendeeCount Attending",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
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
