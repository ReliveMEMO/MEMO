import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void profilePage() {
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  String? selectedProgram;
  PostgrestMap? userDetails;
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
        .eq('id', authService.getCurrentUserID()!)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      userDetails = response;
    });
    userDetails?['user_name'] = authService.getCurrentUser();
    print(response);

    setState(() {
      isLoading = false;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.userDetails = userDetails;
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn = authService.getCurrentUser();

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
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 30,
                    left: 97,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Information Card
                        Container(
                          padding: EdgeInsets.all(12),
                          width: 220,
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
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              // University Logo
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/images/IIT-Campus-Logo.png'),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 45, vertical: 1),
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
                          left: -40,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                child: ClipOval(
                                  child: userDetails?['profile_pic'] != null
                                      ? CachedNetworkImage(
                                          imageUrl: userDetails?['profile_pic']
                                              as String,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 163,
                    left: 50,
                    right: 50,
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
                        SizedBox(height: 15),
                        // Following Button and Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Following Button
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                "Following",
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              child: Icon(
                                Icons.message,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        // TabBar for Bio and Timeline
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
            Expanded(
              child: TabBarView(
                children: [
                  // Timeline Section
                  const Center(
                    child: Text(
                      "User's Timeline goes here.",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  // Bio Section
                  Scaffold(
                    body: SafeArea(
                      child: Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Center(
                                child: Column(
                                  children: [
                                    // Major Section
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            "BEng. Software Engineering",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: -12,
                                          left: 130,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            color: Colors.white,
                                            child: Text(
                                              "Major",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),

                                    // Grad Year, Age, GPA Section
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Grad Year
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 90,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.4)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "2027",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -12,
                                              left: 15,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                color: Colors.white,
                                                child: Text(
                                                  "Grad Year",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Age
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 90,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.4)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "21",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -12,
                                              left: 25,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                color: Colors.white,
                                                child: Text(
                                                  "Age",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // GPA
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 90,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.4)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "3.0",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -12,
                                              left: 30,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                color: Colors.white,
                                                child: Text(
                                                  "GPA",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 30),

                                    // About Section
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 320,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.4)),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "blah blah blah blah\nblah blah blah blah",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: -12,
                                          left: 130,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            color: Colors.white,
                                            child: Text(
                                              "About",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 30),

                                    // Achievements Section
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            top: -15,
                                            left:
                                                120, // Adjust to center the heading
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              color: Colors.white,
                                              child: Text(
                                                "Achievements",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Achievements Section Container
                                          Container(
                                            width: 340,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.4)),
                                            ),
                                            child: GridView.count(
                                              crossAxisCount: 3, // 3 columns
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              childAspectRatio: 0.9,
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20,
                                              children: List.generate(
                                                6,
                                                (index) => Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.emoji_events,
                                                        size: 40,
                                                        color: Colors.purple,
                                                      ),
                                                      SizedBox(height: 12),
                                                      Text(
                                                        "Achievement ${index + 1}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 8,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
