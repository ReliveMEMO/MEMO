import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/services/search_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimelineSearch extends StatefulWidget {
  final Function(Map<String, dynamic>?) timeLineSelected;

  const TimelineSearch({Key? key, required this.timeLineSelected})
      : super(key: key);

  @override
  _TimelineSearchState createState() => _TimelineSearchState();
}

class _TimelineSearchState extends State<TimelineSearch> {
  final authService = AuthService();
  PostgrestList? searchResults;
  Map<String, dynamic>? selectedTimeline;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTimelines();
  }

  Future<void> fetchTimelines() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('Timeline_Table')
        .select()
        .or('admin.eq.${authService.getCurrentUserID()},collaborators.cs.{${authService.getCurrentUserID()}}')
        .order('lastUpdate', ascending: false);

    setState(() {
      searchResults = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TimeLines',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 15),
                  isLoading
                      ? Skeletonizer(
                          enabled: true,
                          child: Column(
                            children: List.generate(
                                3,
                                (index) => ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        height: 50,
                                        color: Colors.grey[300],
                                      ),
                                    )),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: searchResults?.length,
                            itemBuilder: (context, index) {
                              final user = searchResults?[index];
                              return Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                    borderRadius: BorderRadius.circular(
                                        10), // Added border radius
                                    color: Colors.grey[100],
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: ListTile(
                                    onTap: () {
                                      widget.timeLineSelected(
                                          searchResults?[index]);
                                      Navigator.of(context).pop();
                                    },
                                    title: Text(
                                      searchResults?[index]['timeline_name'] ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ));
                            },
                          ),
                        ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10), // Added border radius
                      color: Colors.purple,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/create-timeline');
                      },
                      child: Text(
                        '+ Create Timeline',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
