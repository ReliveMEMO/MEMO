import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:memo/components/collab_popup.dart';
import 'dart:convert';

import 'package:memo/components/post_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_icons/solar_icons.dart';
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
  List<DateTime> dates = [];
  DateTime? selectedDate = DateTime.now();
  final ScrollController scrollController = ScrollController();

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
        .eq('timeline_id', widget.timelineId)
        .order('date', ascending: false);

    // Update the UI with the fetched data

    setState(() {
      timelineData = response;
      dates = response
          .map<DateTime>((post) => DateTime.parse(post['date']))
          .toList();

      isLoading = false;
    });

    print("########################");
    print(timelineData);
    print(dates);
  }

  void scrollToIndex(int index) {
    final itemHeight =
        MediaQuery.of(context).size.height * 0.5; // Adjust the factor as needed

    scrollController.animateTo(
      index * itemHeight,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });

      final index =
          dates.indexWhere((date) => date.isAtSameMomentAs(selectedDate!));
      if (index != -1) {
        scrollToIndex(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort posts by date (latest on top)

    return Scaffold(
      appBar: AppBar(
        title: widget.timelinename == null
            ? Text('Timeline')
            : Text(widget.timelinename),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              SolarIconsBold.usersGroupTwoRounded,
              size: 25,
            ),
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
          : Stack(children: [
              Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: timelineData!.length,
                      itemBuilder: (context, index) {
                        final post = timelineData![index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 5, right: 5),
                          child: PostCard(post: post),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(timelineData!.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          scrollToIndex(index);
                        },
                        child: TimelineDot(
                          index: index,
                          isLast: index == timelineData!.length - 1,
                          isFirst: index == 0,
                        ),
                      );
                    }),
                  )
                ],
              ),
              Positioned(
                bottom: 25,
                right: 0,
                left: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _selectDate(context);
                            },
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!)
                                  : 'Select Date',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]),
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
