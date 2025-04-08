import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatTile extends StatefulWidget {
  final String chatId;
  const ChatTile({super.key, required this.chatId});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  final authService = AuthService();
  final msgEncryption = MsgEncryption();
  final userName = 'Sandinu Pinnawala';
  String? recentMsg = 'Hello there!';
  String time = '10:00 AM';
  bool isSeen = true;
  DateTime? time_stamp;
  final DP =
      'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/1734968788082';
  bool isLoading = false;
  String recieverId = '';
  String senderId = '';
  PostgrestMap? recieverDetails;
  final Color colorLight = const Color.fromARGB(255, 248, 240, 255);
  final Color colorDark = const Color(0xFF7f31c6);

  late String cId;

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

    setState(() {
      recieverDetails = userResponse;
    });

    final messageResponse = await Supabase.instance.client
        .from('ind_message_table')
        .select('message , time_stamp, is_seen, sender_id')
        .eq('chat_id', cId)
        .order('time_stamp', ascending: false)
        .limit(1)
        .single();

    if (!mounted) return;

    setState(() {
      recentMsg =
          msgEncryption.decrypt(messageResponse['message'] ?? 'Sent an Image');
      time = formatTimeStamp(messageResponse['time_stamp']);
      isSeen = messageResponse['is_seen'];
      senderId = messageResponse['sender_id'];
    });

    print(userResponse);

    setState(() {
      isLoading = false;
    });
  }

  String formatTimeStamp(String timeStamp) {
    DateTime dateTime =
        DateTime.parse(timeStamp).toLocal(); // Convert to local time
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return DateFormat.jm().format(dateTime); // Time if it's today
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday'; // Yesterday
    } else {
      return DateFormat.MMMd().format(dateTime); // Date like Dec 24
    }
  }

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
