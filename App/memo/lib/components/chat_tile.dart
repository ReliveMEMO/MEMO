import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatTile extends StatefulWidget {
  final String chatId;
  const ChatTile({super.key, required this.chatId});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  final authService = AuthService();
  final userName = 'Sandinu Pinnawala';
  final recentMsg = 'Hello there!';
  final time = '10:00 AM';
  final DP =
      'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/1734968788082';
  bool isLoading = false;
  String recieverId = '';
  PostgrestMap? recieverDetails;

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
    setState(() {
      recieverDetails = userResponse;
    });
    print(userResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(recieverDetails?['full_name'] ?? 'Unknown User'),
        subtitle: Text(recentMsg),
        leading: CircleAvatar(
          radius: 22,
          child: ClipOval(
              child: recieverDetails?['profile_pic'] != null
                  ? CachedNetworkImage(
                      imageUrl: recieverDetails?['profile_pic'] as String,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.person),
                    )
                  : const Icon(Icons.person, size: 50)),
        ),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
