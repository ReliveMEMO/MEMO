import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTile extends StatefulWidget {
  final String notificationId;
  const NotificationTile({super.key, required this.notificationId});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool isLoading = false;
  String? notificationText;
  String time = 'Just now';
  String? profilePic;
  String? userName;

  @override
  void initState() {
    super.initState();
    getNotificationDetails();
  }

  void getNotificationDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('notification_table')
        .select()
        .eq('id', widget.notificationId)
        .single();

    final userResponse = await Supabase.instance.client
        .from('User_Info')
        .select('full_name, profile_pic')
        .eq('id', response['sender_id'])
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      notificationText = response['message'];
      time = formatTimeStamp(response['created_at']);
      userName = userResponse?['full_name'] ?? 'Unknown User';
      profilePic = userResponse?['profile_pic'];
      isLoading = false;
    });
  }

  String formatTimeStamp(String timeStamp) {
    DateTime dateTime = DateTime.parse(timeStamp).toLocal();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return 'Today';
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: isLoading
          ? Skeletonizer(
              child: ListTile(
                title: Container(width: 100, height: 20, color: Colors.grey),
                subtitle: Container(width: 150, height: 20, color: Colors.grey),
                leading: CircleAvatar(radius: 22, backgroundColor: Colors.grey),
              ),
            )
          : ListTile(
              title: Text(userName ?? 'Unknown User'),
              subtitle: Text(notificationText ?? 'No notification'),
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: profilePic != null
                    ? CachedNetworkImageProvider(profilePic!)
                    : null,
                child: profilePic == null ? Icon(Icons.person) : null,
              ),
              trailing: Text(
                time,
                style: TextStyle(color: Colors.grey),
              ),
            ),
    );
  }
}