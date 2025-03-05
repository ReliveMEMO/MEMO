import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/components/bio_section.dart';
import 'package:memo/components/follow_section.dart';
import 'package:memo/components/timeline_card.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void profilePage() {
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  final String? userId;
  ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  String? selectedProgram;
  PostgrestMap? userDetails;
  List<String> timelineIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void logout() async {
    await authService.signOut();
    if (mounted) {
      Navigator.pushNamed(context, '/login');
    }
  }

  void getUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq(
            'id',
            widget.userId != null
                ? widget.userId!
                : authService.getCurrentUserID()!)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      userDetails = response;
    });
    userDetails?['user_name'] = authService.getCurrentUser();

    PostgrestList? timelines;

    if (widget.userId == null) {
      timelines = await Supabase.instance.client
          .from('Timeline_Table')
          .select('id')
          .or('admin.eq.${authService.getCurrentUserID()},collaborators.cs.{${authService.getCurrentUserID()}}')
          .order('lastUpdate', ascending: false);
      ;
    } else {
      timelines = await Supabase.instance.client
          .from('Timeline_Table')
          .select('id')
          .or('admin.eq.${widget.userId},collaborators.cs.{${widget.userId}}')
          .order('lastUpdate', ascending: false);
      ;
    }

    if (!mounted) return;

    setState(() {
      timelineIds = timelines?.map((e) => e['id'] as String).toList() ?? [];
    });

    setState(() {
      isLoading = false;
    });

    if (userDetails?['id'] == authService.getCurrentUserID()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userDetails = userDetails;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn = userDetails?['display_name'];

    return Scaffold(
      backgroundColor: Colors.white, // Set the entire background to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
          // Wrap the entire content in SingleChildScrollView
          child: Column(
            children: [
              Container(
                // Wrap Stack in a Container with a defined height
                height: 400,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 30,
                      left: 105,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Information Card
                          Container(
                            padding: EdgeInsets.all(12),
                            width: 230,
                            constraints: BoxConstraints(
                              minHeight: 95, // Minimum height for the container
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // University Logo
                                Image.asset(
                                  'assets/images/iit.png',
                                  width: 120,
                                ),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          left: 80,
                                          top: 1,
                                          bottom: 1,
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "LEVEL 05",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Profile Picture with Emoji Overlay
                          Positioned(
                            top: -20,
                            left: -30,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 65,
                                  child: ClipOval(
                                    child: userDetails?['profile_pic'] != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                userDetails?['profile_pic']
                                                    as String,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                          )
                                        : const Icon(Icons.person, size: 50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 170),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Follower Stats
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "100",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "100",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Following",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Timelines",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 11),
                          // User's Name and Handle
                          Column(
                            children: [
                              Text(
                                userDetails?['full_name'] ?? 'Unknown User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 0),
                              Text(
                                userLoggedIn != null
                                    ? '@$userLoggedIn'
                                    : 'Unknown User',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Following Button and Icon
                          FollowSections(
                              userId: widget.userId != null
                                  ? widget.userId
                                  : authService.getCurrentUserID()),
                          SizedBox(height: 5),
                          // TabBar for Bio and Timelines
                          const TabBar(
                            labelColor: Colors.purple,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.purple,
                            tabs: [
                              Tab(text: "Timeline"),
                              Tab(text: "Bio"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Set height to screen height
                    child: TabBarView(
                      children: [
                        // Timeline Section
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                          children: [
                            ...timelineIds.map((id) {
                              return TimelineCard(timelineId: id);
                            }).toList()
                          ],
                        ),
                        // Bio Section
                        bio_section(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

        ),
     ),
);
}
}