import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/services/auth_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/like_service.dart';

class FullPost extends StatefulWidget {
  final PostgrestMap post;

  const FullPost({
    super.key,
    required this.post,
  });

  @override
  State<FullPost> createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  bool liked = false;
  final likeService = LikeService();
  final authservice = AuthService();
  late int likes;

  @override
  void initState() {
    super.initState();
    setTheStates();
  }

  void setTheStates() async {
    setState(() {
      likes = widget.post['likes'] as int;
    });

    final likedList = widget.post['liked_by'] as List;

    if (likedList.contains(authservice.getCurrentUserID())) {
      setState(() {
        liked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        title: Text(widget.post['heading']),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      widget.post['date'],
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                CachedNetworkImage(
                  imageUrl: widget.post['image_url'],
                  width: 400,
                  placeholder: (context, url) => Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[300],
                    child: Center(
                      child: Skeletonizer(
                        child: SizedBox(width: 300, height: 300),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    widget.post['caption'],
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height:
                      100, // Add some padding to avoid overlap with the bottom bar
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0, // Ensure it spans the full width
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    "${100}",
                    style: TextStyle(color: Colors.black45),
                  ),
                  SizedBox(
                    width: 110,
                  ),
                  Icon(
                    SolarIconsBold.mapArrowSquare,
                    size: 22,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
