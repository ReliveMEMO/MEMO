import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTile extends StatefulWidget {
  final String notificationId;
  const NotificationTile({super.key, required this.notificationId});

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}


  @override
  void initState() {
    super.initState();
    cId = widget.chatId;
    getChatDetails();
  }

  void getChatDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('ind_chat_table')
        .select('user1, user2')
        .eq('chat_id', cId)
        .single();

    if (response['user1'] == authService.getCurrentUserID()) {
      recieverId = response['user2'];
    } else {
      recieverId = response['user1'];
    }
    final userResponse = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq('id', recieverId)
        .maybeSingle();

    if (!mounted) return;

    
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSeen || senderId == authService.getCurrentUserID()
            ? Colors.grey[100]
            : colorLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: isLoading
          ? Skeletonizer(
              child: ListTile(
              title: Container(
                width: 100,
                height: 20,
                color: Colors.grey,
                margin: EdgeInsets.symmetric(vertical: 4),
              ),
              subtitle: Container(width: 150, height: 20, color: Colors.grey),
              leading:
                  const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
            ))
          : InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/chat', arguments: {
                  'chatId': cId,
                  'recieverDetails': recieverDetails,
                });
              },
              child: ListTile(
                title: Text(recieverDetails?['full_name'] ?? 'Unknown User'),
                subtitle: Text(recentMsg ?? 'No recent message'),
                leading: CircleAvatar(
                  radius: 22,
                  child: ClipOval(
                      child: recieverDetails?['profile_pic'] != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  recieverDetails?['profile_pic'] as String,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.person),
                            )
                          : const Icon(Icons.person, size: 50)),
                ),
                trailing: Text(
                  isSeen || senderId == authService.getCurrentUserID()
                      ? time
                      : "$time ●",
                  style: TextStyle(
                      color:
                          isSeen || senderId == authService.getCurrentUserID()
                              ? Colors.grey
                              : colorDark),
                ),
              ),
            ),
    );
  }
}