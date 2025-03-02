import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/services/search_service.dart';

class UserSearch extends StatefulWidget {
  final Function(List<String>) onUsersSelected;

  const UserSearch({Key? key, required this.onUsersSelected}) : super(key: key);

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<String> selectedUsers = [];
  final searchService = SearchService();
  String searchValue = '';
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchUsers(' ');
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 600,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Collaborators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Enter username',
                ),
              ),
              const SizedBox(height: 15),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          final isSelected = selectedUsers.contains(user['id']);
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(
                                  10), // Added border radius
                              color: Colors.grey[100],
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            child: CheckboxListTile(
                              title: Text(user['full_name']),
                              secondary: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    user['profile_pic']),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedUsers.add(user['id']);
                                  } else {
                                    selectedUsers.remove(user['id']);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  widget.onUsersSelected(selectedUsers);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    backgroundColor: Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
