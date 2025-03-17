import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/follow.dart';
import 'package:memo/pages/profile_page.dart';

class FollowingFollowerPage extends StatefulWidget {
  final String userId; // Add userId parameter
  final int selectedTab;

  FollowingFollowerPage({required this.userId, required this.selectedTab});

  @override
  _FollowingFollowerPageState createState() => _FollowingFollowerPageState();
}

class _FollowingFollowerPageState extends State<FollowingFollowerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FollowService _followService = FollowService();
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _isLoading = true;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.selectedTab);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId =
        widget.userId; // Use the userId passed to the FollowingFollowerPage
    if (userId != null) {
      final followersData = await _followService.getFollowers(userId);
      final followingData = await _followService.getFollowing(userId);

      print("Followers Data: $followersData");
      print("Following Data: $followingData");

      setState(() {
        _followers = followersData;
        _following = followingData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // You can handle the case where `userId` is null here, like showing an error message.
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.05,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          '@${authService.getCurrentUser()}',
          style: TextStyle(fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.black,
          tabs: [
            Tab(text: "Followers"),
            Tab(text: "Following"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFollowersList(),
                _buildFollowingList(),
              ],
            ),
    );
  }

  Widget _buildFollowersList() {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.purple),
        radius: Radius.circular(10),
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: _followers.length,
          itemBuilder: (context, index) {
            final user = _followers[index];
            print("Building follower: ${user}");
            return _buildUserItem(
              user['User_Info']?['id'] ?? '',
              user['User_Info']?['full_name'] ?? 'Unknown',
              user['User_Info']?['profile_pic'],
              isFollowing: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowingList() {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.purple),
        radius: Radius.circular(10),
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: _following.length,
          itemBuilder: (context, index) {
            final user = _following[index];
            print("Building following: ${user}");
            return _buildUserItem(
              user['User_Info']?['id'],
              user['User_Info']?['full_name'] ?? 'Unknown',
              user['User_Info']?['profile_pic'],
              isFollowing: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserItem(String? userId, String fullName, String? profilePicUrl,
      {required bool isFollowing}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage:
              profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
          backgroundColor: Colors.grey.shade300,
          child: profilePicUrl == null
              ? Icon(Icons.person, color: Colors.black)
              : null,
        ),
        title: Text(fullName),
        trailing: isFollowing
            ? null
            : IconButton(
                icon: Icon(Icons.person_add_alt_1),
                onPressed: () {
                  // No action when pressed (for now)
                },
              ),
        onTap: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(userId: userId),
              ),
            );
          } else {
            print("User ID is null");
          }
        },
      ),
      elevation: 0,
    );
  }
}
