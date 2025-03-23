import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:memo/pages/create_event.dart';
import 'package:memo/pages/event_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class EventTile extends StatefulWidget {
  final String eventId;


  const EventTile({super.key, required this.eventId});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  String imageUrl = '';
  String title = '';
  String date = '';
  bool isAttending = false;
  List<String> attendees = [];

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('events')
          .select('title, image_url, date, attendees')
          .eq('id', widget.eventId)
          .single();

      if (response != null) {
        setState(() {
          title = response['title'];
          imageUrl = response['image_url'];
          date = response['date'];
          attendees = List<String>.from(response['attendees'] ?? []);
          isAttending = attendees.contains(supabase.auth.currentUser?.id);
        });
      }
    } catch (e) {
      print("Error fetching event: $e");
    }

    setState(() => isLoading = false);
  }

  final Function? onTap;

  const EventTile({
    super.key,
    required this.eventId,
    this.onTap,
  });


  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  String imageUrl =
      "https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/page-images/page-images/1742626399885";
  String title = "Loading...";
  String date = "Loading...";
  bool isAttending = false;
  List<String> attendees = [];
  bool isLoading = true;
  List<String> avatarPaths = [];
  List<String> avatars = [];

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .eq('id', widget.eventId)
          .single();

      if (response != null) {
        setState(() {
          title = response['event_name'] ?? "No Title";
          if (response['Date'] != null) {
            final parsedDate = DateTime.tryParse(response['Date']);
            date = parsedDate != null
                ? DateFormat('yyyy-MM-dd')
                    .format(parsedDate) // Format as "YYYY-MM-DD"
                : "Invalid Date";
          } else {
            date = "No Date";
          }
          imageUrl = response['cover'] ?? imageUrl;
          attendees =
              (response['attendance'] as List<dynamic>?)?.cast<String>() ?? [];
          isAttending = attendees.contains(
              authService.getCurrentUserID()); // Replace with actual user ID
          isLoading = false;
        });

        fetchCollabs();
      }
    } catch (e) {
      print("Error fetching event details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCollabs() async {
    if (attendees != null) {
      List<dynamic> firstThreeCollaborators = attendees.take(3).toList();

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
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            width: 180,
            height: 220,
            color: Colors.grey[200],
            child: Center(child: CircularProgressIndicator()),
          )
        : Container(
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: attendees
                            .take(3) // Show up to 3 attendees
                            .map((profilePic) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(profilePic),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAttending ? "Attending" : "Not Attending",
                            style: TextStyle(
                              color: isAttending ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            isAttending ? Icons.check_circle : Icons.circle,
                            color: isAttending ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventPage(
              eventId: widget.eventId,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: isLoading
                        ? Container(
                            height: 170,
                            color: Colors.grey[300],
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 4),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: avatars.map((path) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: CachedNetworkImageProvider(path),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        isAttending ? "Attending" : "Not Attending",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
