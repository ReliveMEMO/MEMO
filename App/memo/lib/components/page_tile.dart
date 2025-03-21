import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageTile extends StatefulWidget {
  final String pageId;
  final bool? isChat;
  final Function? onTap;

  const PageTile({super.key, required this.pageId, this.isChat, this.onTap});

  @override
  State<PageTile> createState() => _PageTileState();
}

class _PageTileState extends State<PageTile> {
  final authService = AuthService();
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
    cId = widget.pageId;
    getChatDetails();
  }

  void getChatDetails() async {
    setState(() {
      isLoading = true;
    });

    final userResponse = await Supabase.instance.client
        .from('page_table')
        .select()
        .eq('id', cId)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      recieverDetails = userResponse;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
              onTap: widget.isChat == true
                  ? () {
                      Navigator.pushNamed(context, '/chat', arguments: {
                        'chatId': cId,
                        'recieverDetails': recieverDetails
                      });
                    }
                  : () {
                      if (widget.onTap != null) {
                        widget.onTap!();
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                    userId: cId,
                                  )));
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ListTile(
                  title: Text(recieverDetails?['page_name'] ?? 'Unknown Page'),
                  leading: CircleAvatar(
                    radius: 22,
                    child: ClipOval(
                        child: recieverDetails?['profile_pic'] != null
                            ? CachedNetworkImage(
                                imageUrl:
                                    recieverDetails?['image_url'] as String,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.person),
                              )
                            : const Icon(Icons.person, size: 50)),
                  ),
                ),
              ),
            ),
    );
  }
}
