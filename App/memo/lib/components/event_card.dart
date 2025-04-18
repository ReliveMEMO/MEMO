import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/pages/event_page.dart';
import 'package:memo/pages/timeLine_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventCard extends StatefulWidget {
  final String eventId;
  const EventCard({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLoading = false;
  PostgrestMap? eventDetails;
  List<String> avatarPaths = [];
  List<String> avatars = [];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('id', widget.eventId)
        .single();

    if (!mounted) return;

    setState(() {
      eventDetails = response;
    });

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

    print(response);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title =
        isLoading ? 'Loading...' : eventDetails?['event_name'] ?? 'No Title';
    // List<String> avatarPaths = [
    //   'assets/images/avatar1.jpg',
    //   'assets/images/avatar2.jpg',
    //   'assets/images/avatar3.jpg',
    // ];
    List<String> avatarPaths =
        (eventDetails?['attendance'] as List<dynamic>?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventPage(eventId: widget.eventId)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 1,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: isLoading
                  ? Skeletonizer(
                      child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ))
                  : CachedNetworkImage(
                      imageUrl: eventDetails?['cover'],
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: avatars.map((path) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: CachedNetworkImageProvider(path),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
