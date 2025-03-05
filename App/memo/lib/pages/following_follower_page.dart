


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:memo/providers/user_provider.dart';

// class FollowingFollowerPage extends StatefulWidget {
//   final int selectedTab; // Add a parameter to indicate the selected tab

//   FollowingFollowerPage({required this.selectedTab}); // Constructor to accept the selectedTab

//   @override
//   _FollowingFollowerPageState createState() => _FollowingFollowerPageState();
// }

// class _FollowingFollowerPageState extends State<FollowingFollowerPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the TabController with the passed selectedTab
//     _tabController = TabController(length: 2, vsync: this, initialIndex: widget.selectedTab);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get user details from the userProvider
//     final userProvider = Provider.of<UserProvider>(context);
//     final userDetails = userProvider.userDetails;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: screenHeight * 0.05,
//         automaticallyImplyLeading: false,
//         flexibleSpace: Padding(
//           padding: EdgeInsets.only(top: screenHeight * 0.04),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 20.0),
//                 child: Image.asset(
//                   'assets/images/TextLogo.png', // Replace with your logo
//                   width: screenWidth * 0.2,
//                   height: screenWidth * 0.2,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(right: 15),
//                 child: CircleAvatar(
//                   radius: 25,
//                   child: ClipOval(
//                     child: CachedNetworkImage(
//                       imageUrl: userDetails?['profile_pic'] ?? '', // Accessing profile picture from userDetails
//                       width: 40,
//                       height: 40,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => CircularProgressIndicator(), // Placeholder while loading
//                       errorWidget: (context, url, error) => Icon(Icons.error), // Error in case the image is invalid
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.purple,
//           labelColor: Colors.purple,
//           unselectedLabelColor: Colors.black,
//           tabs: [
//             Tab(text: "Followers"),
//             Tab(text: "Following"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildFollowersList(),
//           _buildFollowingList(),
//         ],
//       ),
//     );
//   }

//   // Followers Tab
//   Widget _buildFollowersList() {
//     List<String> followers = [
//       '@user1', '@user2', '@user3', '@user4', '@user5',
//       '@user6', '@user7', '@user8', '@user9', '@user10',
//       '@user11', '@user12', '@user13', '@user14', '@user15',
//       '@user16', '@user17', '@user18', '@user19', '@user20',
//     ];

//     return ScrollbarTheme(
//       data: ScrollbarThemeData(
//         thumbColor: MaterialStateProperty.all(Colors.purple),  // Set the thumb color to purple
//         radius: Radius.circular(10),  // Set the corners to be rounded
//       ),
//       child: Scrollbar(
//         child: ListView.builder(
//           itemCount: followers.length,
//           itemBuilder: (context, index) {
//             return _buildUserItem(followers[index], isFollowing: false); // Pass 'false' for followers
//           },
//         ),
//       ),
//     );
//   }

//   // Following Tab
//   Widget _buildFollowingList() {
//     List<String> following = [
//       '@user1', '@user2', '@user3', '@user4', '@user5',
//       '@user6', '@user7', '@user8', '@user9', '@user10',
//       '@user11', '@user12', '@user13', '@user14', '@user15',
//       '@user16', '@user17', '@user18', '@user19', '@user20',
//     ];

//     return ScrollbarTheme(
//       data: ScrollbarThemeData(
//         thumbColor: MaterialStateProperty.all(Colors.purple),  // Set the thumb color to purple
//         radius: Radius.circular(10),  // Set the corners to be rounded
//       ),
//       child: Scrollbar(
//         child: ListView.builder(
//           itemCount: following.length,
//           itemBuilder: (context, index) {
//             return _buildUserItem(following[index], isFollowing: true); // Pass 'true' for following
//           },
//         ),
//       ),
//     );
//   }

//   // User Item Widget (conditionally adding icon based on followers/following)
//   Widget _buildUserItem(String userName, {required bool isFollowing}) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 20, // Size of the profile picture
//           backgroundColor: Colors.grey.shade300, // Empty profile picture (light grey color)
//           child: Icon(Icons.person, color: Colors.black), // Optional icon inside the avatar
//         ),
//         title: Text(userName),
//         trailing: isFollowing 
//           ? null // No icon for following
//           : IconButton(
//               icon: Icon(Icons.person_add_alt_1), // Follow/unfollow icon for followers
//               onPressed: () {
//                 // No action when pressed (for now)
//               },
//             ),
//       ),
//       elevation: 0,
//     );
//   }
// }


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memo/providers/user_provider.dart';

class FollowingFollowerPage extends StatefulWidget {
  final int selectedTab; // Add a parameter to indicate the selected tab

  FollowingFollowerPage({required this.selectedTab}); // Constructor to accept the selectedTab

  @override
  _FollowingFollowerPageState createState() => _FollowingFollowerPageState();
}

class _FollowingFollowerPageState extends State<FollowingFollowerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the passed selectedTab
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.selectedTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user details from the userProvider
    final userProvider = Provider.of<UserProvider>(context);
    final userDetails = userProvider.userDetails;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.05,
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/TextLogo.png', // Replace with your logo
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  radius: 25,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userDetails?['profile_pic'] ?? '', // Accessing profile picture from userDetails
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(), // Placeholder while loading
                      errorWidget: (context, url, error) => Icon(Icons.error), // Error in case the image is invalid
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersList(),
          _buildFollowingList(),
        ],
      ),
    );
  }

  // Followers Tab
  Widget _buildFollowersList() {
    List<String> followers = [
      '@user1', '@user2', '@user3', '@user4', '@user5',
      '@user6', '@user7', '@user8', '@user9', '@user10',
      '@user11', '@user12', '@user13', '@user14', '@user15',
      '@user16', '@user17', '@user18', '@user19', '@user20',
    ];

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.purple),  // Set the thumb color to purple
        radius: Radius.circular(10),  // Set the corners to be rounded
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: followers.length,
          itemBuilder: (context, index) {
            return _buildUserItem(followers[index], isFollowing: false); // Pass 'false' for followers
          },
        ),
      ),
    );
  }

  // Following Tab
  Widget _buildFollowingList() {
    List<String> following = [
      '@user1', '@user2', '@user3', '@user4', '@user5',
      '@user6', '@user7', '@user8', '@user9', '@user10',
      '@user11', '@user12', '@user13', '@user14', '@user15',
      '@user16', '@user17', '@user18', '@user19', '@user20',
    ];

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.purple),  // Set the thumb color to purple
        radius: Radius.circular(10),  // Set the corners to be rounded
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: following.length,
          itemBuilder: (context, index) {
            return _buildUserItem(following[index], isFollowing: true); // Pass 'true' for following
          },
        ),
      ),
    );
  }

  // User Item Widget (conditionally adding icon based on followers/following)
  Widget _buildUserItem(String userName, {required bool isFollowing}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20, // Size of the profile picture
          backgroundColor: Colors.grey.shade300, // Empty profile picture (light grey color)
          child: Icon(Icons.person, color: Colors.black), // Optional icon inside the avatar
        ),
        title: Text(userName),
        // Making each tile tappable (Button)
        onTap: () {
          // No action when pressed for now, can be added later
        },
      ),
      elevation: 0,
    );
  }
}
