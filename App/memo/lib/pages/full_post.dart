import 'package:flutter/material.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              widget.post['date'],
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
