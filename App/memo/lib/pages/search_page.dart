import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/components/user_tile.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/search_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  String searchValue = '';
  bool isLoading = false;
  var searchResults = [];
  bool isSearching = false;
  final searchService = SearchService();
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    loadRecentSearch();
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

  Future<void> saveRecentSearch(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentSearches = prefs.getStringList('recentSearches') ?? [];
    if (!recentSearches.contains(userID)) {
      recentSearches.insert(0, userID);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
      await prefs.setStringList('recentSearches', recentSearches);
    }
    if (recentSearches.contains(userID)) {
      recentSearches.remove(userID);
      recentSearches.insert(0, userID);
      await prefs.setStringList('recentSearches', recentSearches);
    }
    print('======================================');
    print(recentSearches);
    loadRecentSearch();
  }

  Future<void> loadRecentSearch() async {
    print('==========loading=========');
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
      recentSearches = prefs.getStringList('recentSearches') ?? [];
      isLoading = false;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white30,
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/TextLogo.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfilePage();
                    }));
                  },
                  child: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: userDetails?['profile_pic'] == null
                          ? CircularProgressIndicator()
                          : CachedNetworkImage(
                              imageUrl: userDetails?['profile_pic'] ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          //SizedBox(height: 40),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 20.0),
          //       child: Image.asset(
          //         'assets/images/TextLogo.png',
          //         width: 70,
          //         height: 70,
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(right: 20.0),
          //       child: CircleAvatar(
          //         radius: 30,
          //         backgroundImage: userDetails?['profile_pic'] != null
          //             ? CachedNetworkImageProvider(userDetails?['profile_pic'])
          //             : AssetImage('assets/images/default_profile.png'),
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 10),
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
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color.fromRGBO(156, 39, 176, 1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color.fromRGBO(156, 39, 176, 1),
                    tabs: [
                      Tab(text: 'Accounts'),
                      Tab(text: 'Events'),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TabBarView(
                        children: [
                          isSearching
                              ? isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                      itemCount: searchResults.length,
                                      itemBuilder: (context, index) {
                                        final user = searchResults[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 4),
                                          child: UserTile(
                                              userId: user['id'],
                                              onTap: () {
                                                saveRecentSearch(user['id']);
                                              }),
                                        );
                                      },
                                    )
                              : recentSearches.isEmpty
                                  ? Center(
                                      child:
                                          Text('You have no recent searches'))
                                  : ListView.builder(
                                      itemCount: recentSearches.length,
                                      itemBuilder: (context, index) {
                                        final user = recentSearches[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 4),
                                          child: UserTile(
                                            userId: user,
                                            // onTap: () {
                                            //   Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               ProfilePage(
                                            //                 userId:
                                            //                     recentSearches[
                                            //                         index],
                                            //               )));
                                            // },
                                          ),
                                        );
                                      },
                                    ), // Accounts tab
                          Center(
                              child: Text(
                                  'Events section is blank')), // Events tab
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
