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

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with RouteAware {
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
    final userProvider = Provider.of<UserProvider>(context);
    final userDetails = userProvider.userDetails;

    return Scaffold(
      appBar: AppBar(
        // AppBar title has been removed
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/TextLogo.png',
                  width: 70,
                  height: 70,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: userDetails?['profile_pic'] != null
                      ? CachedNetworkImageProvider(userDetails?['profile_pic'])
                      : AssetImage('assets/images/default_profile.png'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(100),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
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
          Expanded(
            child: isSearching
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
                : const Center(child: Text('')),
          ),
        ],
      ),
    );
  }
}
