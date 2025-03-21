import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/components/post_box.dart';
import 'package:memo/pages/full_post.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:memo/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:memo/components/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map<String, dynamic>> memos = [];
  List<String> clickedMemos = [];

  @override
  void initState() {
    super.initState();
    getUser();
    loadClickedMemos();
    _fetchMemos();
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

  Future<void> loadClickedMemos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      clickedMemos = prefs.getStringList('clicked_memos') ?? [];
    });
  }

  Future<void> _fetchMemos() async {
    setState(() {
      isLoading = true;
    });
    final response = await Supabase.instance.client
        .from('Post_Table')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    List<dynamic> data = response;
    setState(() {
      memos = List<Map<String, dynamic>>.from(data);
      _sortMemos();
    });
  }

  void _sortMemos() {
    memos.sort((a, b) {
      bool aClicked = clickedMemos.contains(a['post_id']);
      bool bClicked = clickedMemos.contains(b['post_id']);

      if (aClicked && !bClicked) {
        return 1; // Move clicked posts to the end
      } else if (!aClicked && bClicked) {
        return -1; // Keep non-clicked posts at the top
      } else {
        return 0; // If both are clicked or neither, maintain original order
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveClickedMemo(String memoId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> clickedMemos = prefs.getStringList('clicked_memos') ?? [];
    if (!clickedMemos.contains(memoId)) {
      clickedMemos.add(memoId);
      prefs.setStringList('clicked_memos', clickedMemos);
      setState(() {
        clickedMemos = clickedMemos;
        _sortMemos();
      });
    }
  }

  void onMemoClick(String memoId) async {
    await _saveClickedMemo(memoId);
    print('Memo $memoId clicked');
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoading = true; // Show loading indicator
      memos = []; // Clear existing memos
      clickedMemos = []; // Clear clicked memos
    });

    getUser(); // Fetch user details
    await loadClickedMemos(); // Load clicked memos
    await _fetchMemos(); // Fetch memos

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UserProvider>(context).userDetails;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refreshPage,
              child: ListView.builder(
                itemCount: memos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () async {
                        print(memos[index]['post_id']);
                        onMemoClick(memos[index]['post_id']);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FullPost(post: memos[index]),
                            ));
                      },
                      child: PostBox(post: memos[index]));
                },
              ),
            ),
    );
  }
}
