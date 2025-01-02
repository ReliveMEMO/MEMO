import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/components/chat_tile.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final authService = AuthService();
  final Color colorDark = const Color(0xFF7f31c6);

  final TextEditingController searchController = TextEditingController();
  String searchValue = '';
  bool isLoading = false;

  var chats = [];

  @override
  void initState() {
    super.initState();
    getChatDetails();
  }

  void getChatDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('User_Info')
        .select('chats')
        .eq('id', authService.getCurrentUserID()!)
        .single();

    if (!mounted) return;

    setState(() {
      chats = response['chats'];
      isLoading = false;
    });
  }

  Future<void> _refreshChats() async {
    setState(() {
      chats = []; // Clear the current chat list
    });

    // Fetch the latest chat details and update the state
    getChatDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(100),
          ),
          margin: const EdgeInsets.only(right: 15),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search chat',
              prefixIcon: Icon(
                HugeIcons.strokeRoundedSearch01,
                color: Colors.grey,
                size: 20,
              ),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            HugeIcons.strokeRoundedAddCircleHalfDot,
            color: colorDark,
          ),
          onPressed: () {
            // Add your onPressed logic here
          },
        ),
        titleSpacing: 0, // Reduce the margin around centerTitle
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 25,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userProvider.userDetails['profile_pic'] as String,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChats,
        color: colorDark,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  children: chats
                      .map((chat) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: ChatTile(
                              chatId: chat,
                            ),
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
