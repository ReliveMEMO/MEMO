import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/components/bio_section.dart';
import 'package:memo/components/follow_section.dart';
import 'package:memo/components/timeline_card.dart';
import 'package:memo/pages/create_event.dart';
import 'package:memo/pages/following_follower_page.dart';
import 'package:memo/pages/settings_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/follow.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void pageProfile() {
  runApp(PageProfile());
}

class PageProfile extends StatefulWidget {
  final String? userId;
  PageProfile({Key? key, this.userId}) : super(key: key);

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final authService = AuthService();
  final followService = FollowService();
  String? selectedProgram;
  PostgrestMap? userDetails;
  List<String> timelineIds = [];
  bool isLoading = true;
  bool privateProfile = false;
  bool? adminPage = false;
  String isFollowing = 'not-following';
  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    getPage();
    getFollowCounts();
  }

  void logout() async {
    await authService.signOut();
    if (mounted) {
      Navigator.pushNamed(context, '/login');
    }
  }

  void getFollowCounts() async {
    final followersCount = await followService
        .getFollowersCount(widget.userId ?? authService.getCurrentUserID()!);

    final followingCount = await followService
        .getFollowingCount(widget.userId ?? authService.getCurrentUserID()!);

    setState(() {
      followers = followersCount;
      following = followingCount;
    });
  }

  void getPage() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('page_table')
        .select()
        .eq('id', widget.userId!)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      userDetails = response;
    });

    setState(() {
      adminPage = userDetails?['admin'] == authService.getCurrentUserID();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn = userDetails?['display_name'];

    return Scaffold(
      backgroundColor: Colors.white, // Set the entire background to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        elevation: 0,
        actions: [
          adminPage == true
              ? IconButton(
                  icon: const Icon(Icons.add_box_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (Context) {
                      return CreateEvent(
                        pageId: userDetails?['id'],
                      );
                    }));
                  },
                )
              : Container(),
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 65,
                            child: ClipOval(
                              child: userDetails?['image_url'] != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          userDetails?['image_url'] as String,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                    )
                                  : const Icon(Icons.person, size: 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 150),
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          // Follower Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (Context) {
                                        return FollowingFollowerPage(
                                          selectedTab: 0,
                                        );
                                      }));
                                    },
                                    child: Text(
                                      followers.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
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
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (Context) {
                                        return FollowingFollowerPage(
                                          selectedTab: 1,
                                        );
                                      }));
                                    },
                                    child: Text(
                                      following.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
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
                                    timelineIds.length.toString(),
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
                                userDetails?['page_name'] ?? 'Unknown Page',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          // Following Button and Icon
                          FollowSections(
                            userId: widget.userId,
                          ),
                          SizedBox(height: 5),
                          // TabBar for Bio and Timelines
                          const TabBar(
                            labelColor: Colors.purple,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.purple,
                            tabs: [
                              Tab(text: "Events"),
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
                        GridView.count(
                          crossAxisCount: 2,
                          semanticChildCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          // Disable scrolling for GridView
                          children: [
                            GridTile(child: Text("Event1")),
                            GridTile(child: Text("Event1")),
                            GridTile(child: Text("Event1")),
                            GridTile(child: Text("Event1")),
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
