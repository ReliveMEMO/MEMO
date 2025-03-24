import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/pages/create_page.dart';
import 'package:memo/pages/full_post.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/pages/timeLine_page.dart';
import 'package:memo/services/like_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostBox extends StatefulWidget {
  const PostBox({
    super.key,
    required this.post,
  });

  final PostgrestMap post;

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  bool liked = false;
  final likeService = LikeService();
  late int likes;
  PostgrestMap? userDetails;
  bool isLoading = false;
  String? timelineName;

  @override
  void initState() {
    super.initState();
    setTheStates();
    getUser();
  }

  void setTheStates() async {
    setState(() {
      likes = widget.post['likes'] as int;
    });

    final likedList = widget.post['liked_by'] as List;

    if (likedList.contains(authService.getCurrentUserID())) {
      setState(() {
        liked = true;
      });
    }
  }

  void getUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq('id', widget.post['owner_id'])
        .maybeSingle();

    final tmName = await Supabase.instance.client
        .from('Timeline_Table')
        .select('timeline_name')
        .eq('id', widget.post['timeline_id']);

    if (!mounted) return;

    setState(() {
      userDetails = response;
      isLoading = false;
      timelineName = tmName[0]['timeline_name'];
    });
  }

  Future<void> _saveClickedMemo(String memoId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> clickedMemos = prefs.getStringList('clicked_memos') ?? [];
    if (!clickedMemos.contains(memoId)) {
      clickedMemos.add(memoId);
      prefs.setStringList('clicked_memos', clickedMemos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  userId: widget.post['owner_id'],
                                )));
                  },
                  child: Row(
                    children: [
                      isLoading
                          ? Skeletonizer(
                              child: CircleAvatar(
                              radius: 18,
                            ))
                          : CircleAvatar(
                              radius: 18,
                              backgroundImage: userDetails != null
                                  ? CachedNetworkImageProvider(
                                      userDetails!['profile_pic'])
                                  : AssetImage('assets/images/user.png')
                                      as ImageProvider,
                            ),
                      SizedBox(width: 8),
                      isLoading
                          ? Skeletonizer(child: Text(""))
                          : Text(
                              "@${userDetails!["display_name"] ?? ""}",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimelinePage(
                                  timelineId: widget.post['timeline_id'],
                                  timelinename: timelineName as String,
                                )));
                  },
                  child: Text(
                    "${timelineName ?? ""}",
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: Text(
              widget.post['heading'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                height: 1,
              ),
            ),
          ),
          Center(
            child: Text(widget.post['date'],
                style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
          ),
          SizedBox(height: 10),
          CachedNetworkImage(
            imageUrl: widget.post['image_url'],
            placeholder: (context, url) => Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              child: Center(
                child: Skeletonizer(
                  child: Center(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: isLoading
                ? Skeletonizer(
                    child: Container(
                    width: 100,
                    height: 10,
                  ))
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${userDetails!["display_name"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.w500), // Bold style
                        ),
                        TextSpan(
                          text: widget.post['caption'], // Remaining text
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                liked
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            liked = !liked;
                            likes--;
                          });

                          _saveClickedMemo(widget.post['post_id']);

                          likeService.handleUnLike(
                              widget.post["post_id"],
                              widget.post["owner_id"],
                              likes,
                              widget.post["liked_by"] as List);
                        },
                        child: Icon(
                          SolarIconsBold.like,
                          color: Colors.purple,
                          size: 22,
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            liked = !liked;
                            likes++;
                          });

                          final response = await likeService.handleLike(
                              widget.post["post_id"],
                              widget.post["owner_id"],
                              likes,
                              widget.post["liked_by"] as List);
                          print(response);
                        },
                        child: Icon(
                          SolarIconsOutline.like,
                          size: 19,
                        ),
                      ),
                SizedBox(width: 5),
                Text(
                  likes.toString(),
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(width: 15),
                Icon(
                  HugeIcons.strokeRoundedComment01,
                  size: 18,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  "${0}",
                  style: TextStyle(color: Colors.black45),
                ),
                SizedBox(
                  width: 180,
                ),
                Icon(
                  SolarIconsBold.mapArrowSquare,
                  size: 22,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class Post {
  final String date;
  final String title;
  final String content;
  final int likes;
  final int comments;
  final String imageUrl;

  Post({
    required this.date,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      date: json['date'],
      title: json['title'],
      content: json['content'],
      likes: json['likes'],
      comments: json['comments'],
      imageUrl: json['imageUrl'],
    );
  }
}
