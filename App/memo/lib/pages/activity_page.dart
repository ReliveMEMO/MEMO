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
import 'package:memo/components/notification_tile.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final authService = AuthService();
  bool isLoading = false;
  PostgrestList? activityList;
  PostgrestList? notificationList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchActivity() async {
    setState(() {
      isLoading = true;
    });

    final activityResponse = await Supabase.instance.client
        .from('notification_table')
        .select('id')
        .eq('receiver_id', authService.getCurrentUserID() ?? "")
        .eq('notification_type', 'activity')
        .order('created_at', ascending: false);
    ;

    final notificationResponse = await Supabase.instance.client
        .from('notification_table')
        .select('id')
        .eq('receiver_id', authService.getCurrentUserID() ?? "")
        .eq('notification_type', 'notification')
        .order('created_at', ascending: false);
    ;

    setState(() {
      activityList = activityResponse;
      notificationList = notificationResponse;
      isLoading = false;
    });
  }

  void removeNotification(String id) {
    setState(() {
      notificationList = notificationList!
          .where((notification) => notification['id'] != id)
          .toList();
    });
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
          margin: EdgeInsets.only(top: 30),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityList(),
            _buildNotificationList(),
          ],
        ),
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
        child: isLoading
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Skeletonizer(
                      child: ListTile(
                    title:
                        Container(width: 100, height: 20, color: Colors.grey),
                    subtitle:
                        Container(width: 150, height: 20, color: Colors.grey),
                    leading:
                        CircleAvatar(radius: 22, backgroundColor: Colors.grey),
                  ));
                },
              )
            : ListView.builder(
                itemCount: activityList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10),
                    child: NotificationTile(
                      notificationId: activityList![index]['id'],
                    ),
                  );
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
        child: isLoading
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Skeletonizer(
                      child: ListTile(
                    title:
                        Container(width: 100, height: 20, color: Colors.grey),
                    subtitle:
                        Container(width: 150, height: 20, color: Colors.grey),
                    leading:
                        CircleAvatar(radius: 22, backgroundColor: Colors.grey),
                  ));
                },
              )
            : ListView.builder(
                itemCount: notificationList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10),
                    child: NotificationTile(
                      notificationId: notificationList![index]['id'],
                      onRemove: () =>
                          removeNotification(notificationList![index]['id']),
                    ),
                  );
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
