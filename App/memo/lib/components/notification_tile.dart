import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/services/follow.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTile extends StatefulWidget {
  final String notificationId;
  final VoidCallback? onRemove;

  const NotificationTile(
      {super.key, required this.notificationId, this.onRemove});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  final followService = FollowService();
  bool isLoading = false;
  String? notificationText;
  String time = 'Just now';
  String? profilePic;
  String? userName;
  String? notificationTitle;
  String? userId;

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

    if (response['notification_title'] != null) {
      setState(() {
        notificationTitle = response['notification_title'];
      });
    }

    setState(() {
      notificationText = response['message'];
      time = formatTimeStamp(response['created_at']);
      userName = userResponse?['full_name'] ?? 'Unknown User';
      profilePic = userResponse?['profile_pic'];
      userId = response['sender_id'];
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

  Future<void> handleRequest(bool accept) async {
    if (accept) {
      followService.requestHandle(userId!, true);

      final response =
          await Supabase.instance.client.from('notification_table').update({
        'created_at': DateTime.now().toIso8601String(),
        'message': 'Started following you!',
        'notification_title': 'Follow',
      }).eq('id', widget.notificationId);

      getNotificationDetails();
    } else {
      //await followService.requestHandle(userId!, false);

      final response = await Supabase.instance.client
          .from('notification_table')
          .delete()
          .eq('id', widget.notificationId);

      widget.onRemove!();
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
              contentPadding: EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              title: Text(userName ?? 'Unknown User'),
              subtitle: Text(notificationText ?? 'No notification'),
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: profilePic != null
                    ? CachedNetworkImageProvider(profilePic!)
                    : null,
                child: profilePic == null ? Icon(Icons.person) : null,
              ),
              trailing: notificationTitle == "Follow_Req"
                  ? SizedBox(
                      width: 70,
                      // Adjust the width as needed
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => handleRequest(false),
                                child: Icon(
                                  SolarIconsOutline.closeSquare,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () => handleRequest(true),
                                child: Icon(
                                  SolarIconsBold.checkSquare,
                                  color: Colors.purple,
                                  size: 32,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  : Text(time),
            ),
    );
  }
}
