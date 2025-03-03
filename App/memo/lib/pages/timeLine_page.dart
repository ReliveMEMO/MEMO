import 'package:flutter/material.dart';
import 'package:memo/components/collab_popup.dart';
import 'dart:convert';

import 'package:memo/components/post_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimelinePage extends StatefulWidget {
  final String timelinename;
  final String timelineId;
  const TimelinePage(
      {Key? key, required this.timelineId, required this.timelinename})
      : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  bool? isLoading = false;
  PostgrestList? timelineData;

  @override
  void initState() {
    super.initState();
    fetchTimelineData();
  }

  Future<void> fetchTimelineData() async {
    // Fetch timeline data from the server
    setState(() {
      isLoading = true;
    });

    // Simulate a delay of 2 seconds
    final response = await Supabase.instance.client
        .from('Post_Table')
        .select()
        .eq('timeline_id', widget.timelineId);

    // Update the UI with the fetched data

    setState(() {
      timelineData = response;
      isLoading = false;
    });

    print(timelineData);
  }

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
    ,
    {
      "date": "22nd Oct 2024",
      "title": "Heading",
      "content": "Lorem ipsum blah blah Lorem ipsum blah blah",
      "likes": 50000,
      "comments": 5,
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
      appBar: AppBar(
        title: widget.timelinename == null
            ? Text('Timeline')
            : Text(widget.timelinename),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              // Call the showCustomPopup function when the icon is pressed
              showCustomPopup(context, widget.timelineId);
            },
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: isLoading == true
          ? Skeletonizer(
              child: Container(
              width: 300,
              height: 400,
            ))
          : Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: timelineData!.length,
                    itemBuilder: (context, index) {
                      final post = timelineData![index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 15.0, top: 5, right: 5),
                        child: PostCard(post: post),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(timelineData!.length, (index) {
                    return TimelineDot(
                      index: index,
                      isLast: index == timelineData!.length - 1,
                      isFirst: index == 0,
                    );
                  }),
                )
              ],
            ),
    );
  }
}

class TimelineDot extends StatelessWidget {
  final int index;
  final bool isLast;
  final bool isFirst;

  TimelineDot({required this.index, this.isLast = false, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 10,
        left: 5,
      ),
      height:
          40, // Adjust the height as needed to control the space between dots
      child: Column(
        children: [
          if (isFirst)
            Container(
              height: 5,
            ),
          if (!isFirst)
            Expanded(
              child: Container(
                width: 2,
                color: Colors.grey,
              ),
            ),
          CircleAvatar(
            radius: isFirst ? 13 : 10,
            backgroundColor: Colors.purple,
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
