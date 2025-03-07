import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool liked = true;

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
      body: SingleChildScrollView(
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
              height: 25,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                      ? Icon(
                          SolarIconsBold.like,
                          color: Colors.purple,
                          size: 22,
                        )
                      : Icon(
                          SolarIconsOutline.like,
                          size: 19,
                        ),
                  SizedBox(width: 5),
                  Text(
                    "${100}",
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
            )
          ],
        ),
      ),
    );
  }
}
