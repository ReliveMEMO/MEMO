import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  }
}
