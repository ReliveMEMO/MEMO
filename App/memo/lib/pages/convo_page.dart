import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memo/providers/backend.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/msg_encryption.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'call_pagee.dart'; // Import CallScreen

class convoPage extends StatefulWidget {
  const convoPage({Key? key}) : super(key: key);

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
  final backendURl = Backend.backendUrl;
  final backendWebSocketURL = Backend.websocketURL;

  late WebSocketChannel messagingChannel; // WebSocket for messaging

  final TextEditingController textMessageController = TextEditingController();
  final ValueNotifier<IconData> iconNotifier = ValueNotifier(Icons.mic);
  final ScrollController _scrollController = ScrollController();
  File? _imageFile;
  File? _selectedImage;
  bool imageSelected = false;
  String? imageUrl; // Define imageUrl variable

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    textMessageController.addListener(_updateIcon);

    // Establish WebSocket connection for messaging
    _initializeMessagingWebSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMessages();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 100 &&
        !_loading) {
      _loadMessages();
    }
  }

  void _initializeMessagingWebSocket() {
    try {
      messagingChannel = WebSocketChannel.connect(
        Uri.parse(
            '$backendWebSocketURL/messaging'), // Use the messaging WebSocket server URL
      );
      // messagingChannel = WebSocketChannel.connect(
      //   Uri.parse(
      //       'ws://192.168.1.5:3000/messaging'), // Use the messaging WebSocket server URL
      // );

      // Register the receiver
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String? receiverId = authService.getCurrentUserID();

        final registerMessage = jsonEncode({
          "type": "register",
          "userId": "$receiverId",
        });

        messagingChannel.sink.add(registerMessage);
        print("Receiver registered with ID: $receiverId");
      });

      // Listen for messages
      messagingChannel.stream.listen((message) {
        print("Received WebSocket message: $message"); // Log incoming messages
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

  Future<void> _markMessagesAsSeen() async {
    if (mounted) {
      final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
      final String chatId = arguments['chatId'];

      try {
        final response = await Supabase.instance.client
            .from('ind_message_table')
            .update({'is_seen': true})
            .eq('chat_id', arguments['chatId'])
            .eq('is_seen', false);

        if (response.error != null) {
          print('Error updating messages: ${response.error!.message}');
        } else {
          print('Messages marked as seen');
        }
      } catch (e) {
        print('Error marking messages as seen: $e');
      }
    }
  }

  void _handleIncomingMessage(String message) {
    try {
      final data = jsonDecode(message);
      print("Handling incoming message: $data"); // Log the incoming message

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
      if (data['type'] == 'receiveImgMessage') {
        final newMessage = {
          'sender_id': data['senderId'],
          'image_url': data['image_url'],
          'time_stamp': data['timestamp'],
          'message': null,
        };

        // Update the state to append the new message
        setState(() {
          messages.insert(0, newMessage); // Add the new message to the top
        });
        print("New real-time img message added: $newMessage");
      }
    } catch (e) {
      print("Error handling incoming message: $e");
    }
  }

  Future<void> _loadMessages() async {
    if (_loading) return;
    _loading = true;

    if (mounted) {
      final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
      final String chatId = arguments['chatId'];

      final response = await Supabase.instance.client
          .from('ind_message_table')
          .select('msg_id,sender_id, message, time_stamp, image_url')
          .eq('chat_id', chatId)
          .order('time_stamp', ascending: false)
          .range(
              _currentBatch * _batchSize, (_currentBatch + 1) * _batchSize - 1);

      if (response != null && response.isNotEmpty) {
        setState(() {
          messages.addAll(response
              .map((msg) => {
                    'message_id': msg['msg_id'],
                    'sender_id': msg['sender_id'],
                    if (msg['message'] != null) 'message': msg['message'],
                    if (msg['image_url'] != null) 'image_url': msg['image_url'],
                    'time_stamp': msg['time_stamp'],
                  })
              .toList());

          print(messages);
          _currentBatch++;
          _loading = false;
        });
      } else {
        _loading = false;
      }
    }
    _markMessagesAsSeen();
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

      final String chatId = arguments['chatId'];
      print(chatId + " chatId");
      final response = await Supabase.instance.client
          .from('ind_chat_table')
          .update({
        'last_accessed': DateTime.now().toUtc().toIso8601String()
      }).eq('chat_id', chatId);

      messagingChannel.sink.add(messagePayload);
      print("Sent message payload: $messagePayload"); // Log the sent message

      if (response.error != null) {
        print("Error updating last_accessed: ${response.error!.message}");
      } else {
        print("last_accessed updated successfully");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final response = await Supabase.instance.client
            .from('ind_message_table')
            .update({
          'message': "This message has been deleted",
          'image_url': null
        }).eq('msg_id', messageId);

        if (response != null) {
          print("Error deleting message: ${response.error!.message}");
        } else {
          print("Message deleted successfully");

          // Update the message in the local list
          setState(() {
            final index = messages
                .indexWhere((message) => message['message_id'] == messageId);
            if (index != -1) {
              messages[index]['message'] = "This message has been deleted";
              messages[index]['isEncrypted'] = false;
              messages[index]['image_url'] = null; // Clear image URL if any
            }
          });
        }
      } catch (e) {
        print("Error deleting message: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedImage != null ? File(pickedImage.path) : null;
      imageSelected = _selectedImage != null;
    });

    if (imageSelected) {
      _showImagePreviewDialog();
    }
  }

  void _showImagePreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Set your desired radius
          ),
          child: Stack(children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
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
                      return Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      );
                    },
                  ),
                  onPressed: () {
                    if (imageSelected) {
                      // Logic for sending a message
                      _sendImageMessage();
                      print("Message sent: ${textMessageController.text}");

                      setState(() {
                        imageSelected = false;
                        _selectedImage = null; // Clear the selected image
                        imageUrl = null; // Clear the image URL
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            )
          ]),
        );
      },
    );
  }

  Future<void> uploadImage() async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    await Supabase.instance.client.storage
        .from('message-media')
        .upload(path, _selectedImage!);

    final url = await Supabase.instance.client.storage
        .from('message-media')
        .getPublicUrl(path);

    imageUrl = url;
  }

  Future<void> _sendImageMessage() async {
    if (!imageSelected) return;

    await uploadImage(); // Upload the image and get the URL

    try {
      final String? senderId = authService.getCurrentUserID();
      final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
      final recieverDetails = arguments['recieverDetails'];
      print(recieverDetails);
      final String recieverId =
          recieverDetails['id']; // Adjust key as per actual argument

      print(recieverId);

      if (imageUrl == null) {
        await Future.delayed(
            const Duration(seconds: 1)); // Add a 2-second delay
      }

      // Create a message object to append to the UI
      final newMessage = {
        'sender_id': senderId,
        'image_url': imageUrl,
        'time_stamp': DateTime.now().toIso8601String(),
      };

      // Append to the messages list immediately
      setState(() {
        messages.insert(0, newMessage);
      });

      // Send the message via WebSocket
      final messagePayload = jsonEncode({
        "type": "sendImage",
        "senderId": senderId,
        "receiverId": recieverId,
        "image_url": imageUrl,
      });

      final String chatId = arguments['chatId'];
      print(chatId + " chatId");
      final response = await Supabase.instance.client
          .from('ind_chat_table')
          .update({
        'last_accessed': DateTime.now().toUtc().toIso8601String()
      }).eq('chat_id', chatId);

      messagingChannel.sink.add(messagePayload);
      print("Sent message payload: $messagePayload"); // Log the sent message

      if (response.error != null) {
        print("Error updating last_accessed: ${response.error!.message}");
      } else {
        print("last_accessed updated successfully");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();

    // Close WebSocket connection
    messagingChannel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;
    final recieverDetails = arguments['recieverDetails'];
    final String calleeId = recieverDetails['id'];
    final String calleeProfilePic = recieverDetails['profile_pic'] as String;

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
                //onpress logic here
              }),
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
                    controller: _scrollController,
                    reverse:
                        true, // Updated to ensure recent messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message['sender_id'] ==
                          authService.getCurrentUserID();
                      final messageTime = DateTime.parse(message['time_stamp'])
                          .toLocal(); // Assuming 'timestamp' is in ISO 8601 format
                      final formattedTime = DateFormat('hh:mm a').format(
                          messageTime); // Using intl package for formatting
                      final formattedDate =
                          DateFormat('dd MMM yyyy').format(messageTime);

                      bool showDateHeader = true;
                      if (index < messages.length - 1) {
                        final nextMessageTime =
                            DateTime.parse(messages[index + 1]['time_stamp'])
                                .toLocal();
                        final nextFormattedDate =
                            DateFormat('dd MMM yyyy').format(nextMessageTime);
                        showDateHeader = formattedDate != nextFormattedDate;
                      }

                      return GestureDetector(
                        onLongPress: () {
                          if (isSender) {
                            if (message['message_id'] != null) {
                              deleteMessage(message['message_id']);
                            }
                            print(message);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                          fontSize: 12,
                                          color: Colors.grey[700]),
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
                                    message['image_url'] != null
                                        ? GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                barrierColor:
                                                    const Color.fromARGB(
                                                        221, 0, 0, 0),
                                                builder: (context) {
                                                  return Dialog(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          message['image_url']
                                                              as String,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      placeholder: (context,
                                                              url) =>
                                                          const CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 250,
                                                maxHeight: 250,
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: message['image_url']
                                                    as String,
                                                placeholder: (context, url) =>
                                                    SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: const Center(
                                                      child: SpinKitPulse(
                                                    color: Colors.purple,
                                                    size: 30.0,
                                                  )),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          )
                                        : Builder(
                                            builder: (context) {
                                              final decryptedMessage = message[
                                                          "message"] !=
                                                      null
                                                  ? (message.containsKey(
                                                          'isEncrypted')
                                                      ? message['message']
                                                      : (message['message'] ==
                                                              "This message has been deleted"
                                                          ? 'This message has been deleted'
                                                          : msgEncryption.decrypt(
                                                                  message[
                                                                      'message']) ??
                                                              'Decryption failed'))
                                                  : '';

                                              // Check if the decrypted message is a single emoji
                                              final isSingleEmoji = RegExp(
                                                      r'^[\u{1F1E6}-\u{1F1FF}' + // Regional indicator symbols (flags)
                                                          r'\u{1F300}-\u{1F5FF}' + // Miscellaneous Symbols and Pictographs
                                                          r'\u{1F600}-\u{1F64F}' + // Emoticons
                                                          r'\u{1F680}-\u{1F6FF}' + // Transport and Map Symbols
                                                          r'\u{1F700}-\u{1F77F}' + // Alchemical Symbols
                                                          r'\u{1F780}-\u{1F7FF}' + // Geometric Shapes Extended
                                                          r'\u{1F800}-\u{1F8FF}' + // Supplemental Arrows-C
                                                          r'\u{1F900}-\u{1F9FF}' + // Supplemental Symbols and Pictographs
                                                          r'\u{1FA00}-\u{1FA6F}' + // Chess Symbols
                                                          r'\u{1FA70}-\u{1FAFF}' + // Symbols and Pictographs Extended-A
                                                          r'\u{2600}-\u{26FF}' + // Miscellaneous Symbols
                                                          r'\u{2700}-\u{27BF}' + // Dingbats
                                                          r'\u{FE0F}' + // Variation Selector-16 (emoji variation)
                                                          r']$',
                                                      unicode: true)
                                                  .hasMatch(
                                                      decryptedMessage.trim());

                                              return Text(
                                                decryptedMessage,
                                                style: TextStyle(
                                                  fontSize: isSingleEmoji
                                                      ? 48
                                                      : 16, // Larger font size for single emoji
                                                ),
                                              );
                                            },
                                          ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                  _pickImage();
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
