import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TimelineCard extends StatelessWidget {
  final String timelineId;

  const TimelineCard({Key? key, required this.timelineId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath =
        'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/timeline_covers/uploads/1739791244867';
    String title = 'Timeline 1';
    // List<String> avatarPaths = [
    //   'assets/images/avatar1.jpg',
    //   'assets/images/avatar2.jpg',
    //   'assets/images/avatar3.jpg',
    // ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(imageUrl: imagePath),
          ),
          // Positioned(
          //   top: 8,
          //   left: 8,
          //   child: Row(
          //     children: avatarPaths.map((path) {
          //       return Padding(
          //         padding: const EdgeInsets.only(right: 4),
          //         child: CircleAvatar(
          //           radius: 12,
          //           backgroundImage: AssetImage(path),
          //         ),
          //       );
          //     }).toList(),
          //   ),
          // ),
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
    );
  }
}
