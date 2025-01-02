import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:memo/providers/chats_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  double bottomInsets = 0;

  late WebSocketChannel channel;
  late ChatProvider chatProvider;

  final TextEditingController textMessageController = TextEditingController();
  final ValueNotifier<IconData> iconNotifier = ValueNotifier(Icons.mic);

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    _loadMessages();
    textMessageController.addListener(_updateIcon);

    // Establish WebSocket connection and register receiver
    _initializeWebSocket();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  void _initializeWebSocket() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse(
            'ws://192.168.1.4:3000'), // Replace with your WebSocket server URL
      );

      // Register the receiver
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String? receiverId = authService.getCurrentUserID();

        final registerMessage = jsonEncode({
          "type": "register",
          "userId": "$receiverId",
        });

        channel.sink.add(registerMessage);
        print("Receiver registered with ID: $receiverId");
      });

      // Listen for messages
      channel.stream.listen((message) {
        _handleIncomingMessage(message);
      }, onError: (error) {
        print("WebSocket error: $error");
      }, onDone: () {
        print("WebSocket connection closed.");
      });
    } catch (e, stackTrace) {
      print("WebSocket initialization error: $e\n$stackTrace");
    }
  }

  void _handleIncomingMessage(String message) {
    try {
      final data = jsonDecode(message);

      // Check if the incoming message type is a real-time message
      if (data['type'] == 'receiveMessage') {
        final newMessage = {
          'sender_id': data['senderId'],
          'message': data['message'],
          'time_stamp': data['timestamp'],
        };

        // Update the state to append the new message
        setState(() {
          messages.insert(0, newMessage); // Add the new message to the top
        });
        print("New real-time message added: $newMessage");
      }
    } catch (e) {
      print("Error handling incoming message: $e");
    }
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
      if (mounted) {
        setState(() {
          messages.addAll(response);
          _currentBatch++;
          _loading = false;
        });
      } else {
        _loading = false;
      }
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

  void _updateIcon() {
    if (textMessageController.text.isEmpty) {
      iconNotifier.value = Icons.mic;
    } else {
      iconNotifier.value = Icons.send;
    }
    print("Icon updated to: ${iconNotifier.value}");
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    try {
      final String? senderId = authService.getCurrentUserID();
      final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
      final recieverDetails = arguments['recieverDetails'];
      print(recieverDetails);
      final String recieverId =
          recieverDetails['id']; // Adjust key as per actual argument

      print(recieverId);

      final String encryptedMessage = text;

      // Create a message object to append to the UI
      final newMessage = {
        'sender_id': senderId,
        'message': text,
        'time_stamp': DateTime.now().toIso8601String(),
        'isEncrypted': false,
      };

      // Append to the messages list immediately
      setState(() {
        messages.insert(0, newMessage);
      });

      // Send the message via WebSocket
      final messagePayload = jsonEncode({
        "type": "sendMessage",
        "senderId": senderId,
        "receiverId": recieverId,
        "message": encryptedMessage,
      });

      channel.sink.add(messagePayload);
      chatProvider.addChat(arguments['chatId']);
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();

    // Close WebSocket connection
    channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final String chatId = arguments['chatId'];
    final recieverDetails = arguments['recieverDetails'];

    // Detect keyboard height
    bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/chat_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Column(
              children: [
                // Adjust height of the messages container
                Expanded(
                  flex: bottomInsets > 0 ? 3 : 4,
                  child: ListView.builder(
                    controller: scrollController,
                    reverse:
                        true, // Updated to ensure recent messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message['sender_id'] ==
                          authService.getCurrentUserID();
                      final messageTime = DateTime.parse(message[
                          'time_stamp']); // Assuming 'timestamp' is in ISO 8601 format
                      final formattedTime = DateFormat('hh:mm a').format(
                          messageTime); // Using intl package for formatting
                      final formattedDate =
                          DateFormat('dd MMM yyyy').format(messageTime);

                      bool showDateHeader = true;
                      if (index < messages.length - 1) {
                        final nextMessageTime =
                            DateTime.parse(messages[index + 1]['time_stamp']);
                        final nextFormattedDate =
                            DateFormat('dd MMM yyyy').format(nextMessageTime);
                        showDateHeader = formattedDate != nextFormattedDate;
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
                                      message.containsKey('isEncrypted')
                                          ? message['message']
                                          : msgEncryption.decrypt(
                                                  message['message']) ??
                                              'Decryption failed',
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
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            bottom: 25 + bottomInsets, left: 10, right: 10, top: 5),
        child: Row(
          children: [
            // Camera Button
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.purple, // Background color
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: () {
                  // Add logic for camera
                },
              ),
            ),
            const SizedBox(
                width: 10), // Spacing between camera and gray container
            // Gray Container with TextField and Emoji Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Background color for the container
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Row(
                  children: [
                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: textMessageController,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    // Emoji Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors
                            .transparent, // Background color for emoji button
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.grey, size: 25),
                        onPressed: () {
                          setState(() {
                            bottomInsets =
                                MediaQuery.of(context).viewInsets.bottom;
                          });
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                height: MediaQuery.of(context).size.height *
                                    0.5, // Adjust the height as needed
                                child: EmojiPicker(
                                  onEmojiSelected: (category, emoji) {
                                    textMessageController.text += emoji.emoji;
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
                width: 10), // Spacing between gray container and microphone
            // Microphone Button
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.purple, // Background color
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: ValueListenableBuilder<IconData>(
                  valueListenable: iconNotifier,
                  builder: (context, value, child) {
                    print("Building Icon: $value");
                    return Icon(
                      value,
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
                onPressed: () {
                  if (textMessageController.text.isNotEmpty) {
                    // Logic for sending a message
                    _sendMessage(textMessageController.text);
                    print("Message sent: ${textMessageController.text}");
                    textMessageController.clear();
                  } else {
                    // Logic for microphone input
                    print("Microphone activated");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
