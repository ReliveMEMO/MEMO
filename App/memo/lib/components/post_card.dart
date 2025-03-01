import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
            SizedBox(height: 2),
            Text(widget.post.date,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple)),
            SizedBox(height: 15),
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
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
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.post.content,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thumb_up, size: 18),
                  SizedBox(width: 5),
                  Text("${widget.post.likes} likes"),
                  SizedBox(width: 15),
                  Icon(Icons.comment, size: 18),
                  SizedBox(width: 5),
                  Text("${widget.post.comments} comments"),
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
