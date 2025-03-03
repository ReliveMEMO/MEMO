import 'package:flutter/material.dart';
import 'package:memo/components/notification_tile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> notifications = [
    {
      'userName': '@sir_techghost2',
      'message': 'is now following you!',
      'profilePic': 'https://i.pravatar.cc/150?img=1',
      'time': 'Today',
    },
    {
      'userName': '@sir_techghost2',
      'message': 'liked your memo',
      'profilePic': 'https://i.pravatar.cc/150?img=2',
      'time': 'Just now',
    },
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'memo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Friends Activity'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text('Friends Activity Content')), // Placeholder
          ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index];
             
            },
          ),
        ],
      ),
    );
  }
}
