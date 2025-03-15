import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:memo/components/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  String? selectedProgram;
  PostgrestMap? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
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

    PostgrestList? timelines;

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
    final userDetails = Provider.of<UserProvider>(context).userDetails;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    List<Map<String, dynamic>> posts = [
      {
        'heading': 'Post 1 Title',
        'date': '2025-03-10',
        'image_url':
            'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/memos/uploads/1741159042068',
        'caption': ' fisrt post caption.',
        'likes': 0,
        'comments': 50,
        'liked_by': [],
      },
      {
        'heading': 'Post 2 Title',
        'date': '2025-03-09',
        'image_url':
            'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/memos/uploads/1741076511660',
        'caption': ' second post caption.',
        'likes': 150,
        'comments': 30,
        'liked_by': [],
      },
      {
        'heading': 'Post 2 Title',
        'date': '2025-03-09',
        'image_url':
            'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/memos/uploads/1741067741540',
        'caption': ' second post caption.',
        'likes': 150,
        'comments': 30,
        'liked_by': [],
      },
    ];

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        ),
      ),
    );
  }
}
