import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/pages/create_page.dart';
import 'package:memo/pages/full_post.dart';
import 'package:memo/services/like_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onDelete, // Add this callback
  });

  final PostgrestMap post;
  final VoidCallback onDelete; // Callback to notify parent

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  final likeService = LikeService();
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

    if (likedList.contains(authService.getCurrentUserID())) {
      setState(() {
        liked = true;
      });
    }
  }

  Future<void> deleteMemo() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Memo"),
          content: Text("Are you sure you want to delete this memo?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final response = await Supabase.instance.client
          .from('Post_Table')
          .delete()
          .eq('post_id', widget.post['post_id']);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to delete memo"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Memo deleted"),
        ));

        // Refresh the screen by updating the state
        widget.onDelete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      elevation: 1,
      color: widget.post['owner_id'] == authService.getCurrentUserID()
          ? Colors.grey[100]
          : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post['heading'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            SizedBox(height: 2),
            Text(widget.post['date'],
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple)),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullPost(post: widget.post)));
              },
              onLongPress: () {
                if (widget.post['owner_id'] == authService.getCurrentUserID()) {
                  deleteMemo();
                }
              },
              child: CachedNetworkImage(
                imageUrl: widget.post['image_url'],
                placeholder: (context, url) => Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: Center(
                    child: Skeletonizer(
                      child: Center(child: SizedBox(width: 300, height: 300)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.post['caption'],
              ),
            ),
            SizedBox(height: 20),
            Container(
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
                    "${0}",
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
            )
          ],
        ),
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
