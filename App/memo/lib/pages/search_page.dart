import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/components/chat_tile.dart';
import 'package:memo/components/user_tile.dart';
import 'package:memo/main.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/search_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with RouteAware {
  final TextEditingController searchController = TextEditingController();
  String searchValue = '';
  bool isLoading = false;

  var searchResults = [];
  bool isSearching = false;
  final searchService = SearchService();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchValue = searchController.text;
      if (searchValue.isEmpty) {
        isSearching = false;
        searchResults = [];
      } else {
        isSearching = true;
        _searchUsers(searchValue);
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await searchService.searchUsers(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
      print(results);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error Searching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: isSearching
          ? isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final user = searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 4),
                      child: UserTile(userId: user['id']),
                    );
                  },
                )
          : const Center(child: Text('Start searching...')),
    );
  }
}