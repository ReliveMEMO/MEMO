import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/services/auth_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final authService = AuthService();

  final TextEditingController searchController = TextEditingController();
  String searchValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(100),
          ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 25,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/1734972663961',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
