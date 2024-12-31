import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
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
  final scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  final int _batchSize = 20;
  bool _loading = false;
  int _currentBatch = 0;

  @override
  void initState() {
    super.initState();
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
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender =
                        message['sender_id'] == authService.getCurrentUserID()
                            ? true
                            : false;
                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: message['imageUrl'] != null
                            ? CachedNetworkImage(
                                imageUrl: message['imageUrl'] as String,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Text(
                                msgEncryption.decrypt(message['message'])!,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ]));
  }
}
