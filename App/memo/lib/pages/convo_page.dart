import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class convoPage extends StatefulWidget {
  const convoPage({super.key});

  @override
  State<convoPage> createState() => _convoPageState();
}

class _convoPageState extends State<convoPage> {
  final authService = AuthService();
  final msgEncryption = MsgEncryption();
  var scrollController;
  final List<Map<String, dynamic>> messages = [];
  final int _batchSize = 20;
  bool _loading = false;
  int _currentBatch = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_loading) return;
    _loading = true;
    // Add your loading logic here
    await Future.delayed(Duration(seconds: 1));

    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final String chatId = arguments['chatId'];

    final response = await Supabase.instance.client
        .from('ind_message_table')
        .select('sender_id, message, time_stamp')
        .eq('chat_id', chatId)
        .order('time_stamp', ascending: false)
        .range(
            _currentBatch * _batchSize, (_currentBatch + 1) * _batchSize - 1);

    if (response != null) {
      setState(() {
        messages.addAll(response);
        _currentBatch++;
        _loading = false;
      });
    } else {
      // Handle error
      _loading = false;
    }
  }

  void _scrollListener() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == 0) {
        // At the top
      } else {
        // At the bottom
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final String chatId = arguments['chatId'];
    final recieverDetails = arguments['recieverDetails'];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: recieverDetails['profile_pic'] as String,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              recieverDetails['full_name'] as String,
              style: TextStyle(fontSize: 20, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedCall02),
            onPressed: () {
              // Add your onPressed logic here
            },
          ),
        ],
      ),
      body: Stack(children: [
        Positioned.fill(
            child: Image.asset(
          'assets/images/chat_bg.jpg',
          fit: BoxFit.cover,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  reverse: messages.length > 1,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender =
                        message['sender_id'] == authService.getCurrentUserID();
                    final messageTime = DateTime.parse(message[
                        'time_stamp']); // Assuming 'timestamp' is in ISO 8601 format
                    final formattedTime = DateFormat('hh:mm a').format(
                        messageTime); // Using intl package for formatting
                    final formattedDate =
                        DateFormat('dd MMM yyyy').format(messageTime);

                    bool showDateHeader = true;
                    if (index > 0) {
                      final previousMessageTime =
                          DateTime.parse(messages[index - 1]['time_stamp']);
                      final previousFormattedDate =
                          DateFormat('dd MMM yyyy').format(previousMessageTime);
                      showDateHeader = formattedDate != previousFormattedDate;
                    }

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (message['imageUrl'] != null)
                                    CachedNetworkImage(
                                      imageUrl: message['imageUrl'] as String,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  else
                                    Text(
                                      msgEncryption
                                          .decrypt(message['message'])!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]);
                  },
                ),
              ),
            ],
          ),
        ),
      ]),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  // Add logic for camera
                },
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
              ),
            ],
          )),
    );
  }
}
