// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:memo/providers/user_provider.dart';
// import 'package:provider/provider.dart';

// class ActivityPage extends StatefulWidget {
//   @override
//   _ActivityPageState createState() => _ActivityPageState();
// }

// class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                   'assets/images/TextLogo.png',
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
//                       imageUrl: userDetails?['profile_pic'] as String? ?? '',
//                       width: 40,
//                       height: 40,
//                       fit: BoxFit.cover,
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
//             Tab(text: "Friends Activity"),
//             Tab(text: "Notifications"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildActivityList(),
//           _buildNotificationList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityList() {
//     List<String> activities = [
//       "@sir.techghost2 added a new memo",
//       "@sir.techghost2's birthday is in 2 weeks",
//       "@sir.techghost2 is going to spandanal",
//       "@sir.techghost2 added a new memo",
//       "@sir.techghost2's birthday is in 2 weeks",
//       "@sir.techghost2 is going to spandanal",
//       "@sir.techghost2 added a new memo",
//       "@sir.techghost2 added a new memo",
//       "@sir.techghost2's birthday is in 2 weeks",
//       "@sir.techghost2 is going to spandanal",
//       "@sir.techghost2 added a new memo",
//       "@sir.techghost2's birthday is in 2 weeks",
//       "@sir.techghost2 is going to spandanal",
//       "@sir.techghost2 added a new memo",

//     ];

//     return ListView.builder(
//       itemCount: activities.length,
//       itemBuilder: (context, index) {
//         return _buildActivityItem(activities[index]);
//       },
//     );
//   }

//   Widget _buildNotificationList() {
//     List<String> notifications = [
//       "@sir.techghost2 is now following you!",
//       "@sir.techghost2 liked your memo",
//       "@sir.techghost2 tagged you in a memo",
//       "@sir.techghost2 is now following you!",
//       "@sir.techghost2 liked your memo",
//       "@sir.techghost2 tagged you in a memo",
//       "@sir.techghost2 is now following you!",
//     ];

//     return ListView.builder(
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         return _buildNotificationItem(notifications[index]);
//       },
//     );
//   }

//   Widget _buildActivityItem(String text) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.grey.shade300,
//           child: Icon(Icons.person, color: Colors.black),
//         ),
//         title: Text(text),
//       ),
//       elevation: 0,
//     );
//   }

//   Widget _buildNotificationItem(String text) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.grey.shade300,
//           child: Icon(Icons.notifications, color: Colors.black),
//         ),
//         title: Text(text),
//       ),
//       elevation: 0,
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'assets/images/TextLogo.png',
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userDetails?['profile_pic'] as String? ?? '',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.black,
          tabs: [
            Tab(text: "Friends Activity"),
            Tab(text: "Notifications"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityList(),
          _buildNotificationList(),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    List<String> activities = [
      "@sir.techghost2 added a new memo",
      "@sir.techghost2's birthday is in 2 weeks",
      "@sir.techghost2 is going to spandanal",
      "@sir.techghost2 added a new memo",
      "@sir.techghost2's birthday is in 2 weeks",
      "@sir.techghost2 is going to spandanal",
      "@sir.techghost2 added a new memo",
      "@sir.techghost2 added a new memo",
      "@sir.techghost2's birthday is in 2 weeks",
      "@sir.techghost2 is going to spandanal",
      "@sir.techghost2 added a new memo",
      "@sir.techghost2's birthday is in 2 weeks",
      "@sir.techghost2 is going to spandanal",
      "@sir.techghost2 added a new memo",
    ];

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
            Colors.purple), // Set the thumb color to purple
        radius: Radius.circular(10), // Set the corners to be rounded
        //thickness: MaterialStateProperty.all(8),  // Keeping default thickness (no change)
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return _buildActivityItem(activities[index]);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    List<String> notifications = [
      "@sir.techghost2 is now following you!",
      "@sir.techghost2 liked your memo",
      "@sir.techghost2 tagged you in a memo",
      "@sir.techghost2 is now following you!",
      "@sir.techghost2 liked your memo",
      "@sir.techghost2 tagged you in a memo",
      "@sir.techghost2 is now following you!",
      "@sir.techghost2 is now following you!",
      "@sir.techghost2 liked your memo",
      "@sir.techghost2 tagged you in a memo",
      "@sir.techghost2 is now following you!",
      "@sir.techghost2 liked your memo",
      "@sir.techghost2 tagged you in a memo",
      "@sir.techghost2 is now following you!",
    ];

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(
            Colors.purple), // Set the thumb color to purple
        radius: Radius.circular(10), // Set the corners to be rounded
      ),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationItem(notifications[index]);
          },
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person, color: Colors.black),
        ),
        title: Text(text),
      ),
      elevation: 0,
    );
  }

  Widget _buildNotificationItem(String text) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.notifications, color: Colors.black),
        ),
        title: Text(text),
      ),
      elevation: 0,
    );
  }
}
