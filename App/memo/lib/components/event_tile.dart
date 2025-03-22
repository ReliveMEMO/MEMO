import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final String date;
  final bool isAttending;
  final List<String> attendees;

  const EventTile({
    super.key,
    required this.eventId,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.isAttending,
    required this.attendees,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  children: attendees.map((profilePic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(profilePic),
                      ),
                    );
                  }).toList(),
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
