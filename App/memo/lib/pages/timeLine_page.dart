import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:memo/components/post_card.dart';

class TimelinePage extends StatefulWidget {
  final String timelineId;
  const TimelinePage({Key? key, required this.timelineId}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final String jsonData = '''
  [
    {
      "date": "11th Nov 2024",
      "title": "Journey of the life",
      "content": "Lorem ipsum blah blah Lorem ipsum blah blah",
      "likes": 100000,
      "comments": 10,
      "imageUrl": "https://i.pinimg.com/originals/35/77/cc/3577cc8ffbaa0797b446942ef44df9cc.jpg"
    },
    {
      "date": "22nd Oct 2024",
      "title": "Heading",
      "content": "Lorem ipsum blah blah Lorem ipsum blah blah",
      "likes": 50000,
      "comments": 5,
      "imageUrl": "https://i.pinimg.com/originals/35/77/cc/3577cc8ffbaa0797b446942ef44df9cc.jpg"
    }
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    List<Post> posts = (json.decode(jsonData) as List)
        .map((data) => Post.fromJson(data))
        .toList();

    // Sort posts by date (latest on top)
    posts.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text("Timeline")),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 5, right: 5),
                  child: PostCard(post: post),
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(posts.length, (index) {
              return TimelineDot(date: posts[index].date, index: index);
            }),
          )
        ],
      ),
    );
  }
}

class TimelineDot extends StatelessWidget {
  final String date;
  final int index;

  TimelineDot({required this.date, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}
