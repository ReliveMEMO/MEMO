import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:memo/pages/chat_page.dart';
import 'package:memo/pages/create_profile.dart';
import 'package:memo/pages/create_timeline.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:memo/pages/search_page.dart';
class myPage extends StatefulWidget {
  const myPage({super.key});

  @override
  State<myPage> createState() => _myPageState();
}

class _myPageState extends State<myPage> {
  final Color colorDark = const Color(0xFF7f31c6);

  List pages = [
    ProfilePage(),
    SearchPage(),
    ProfilePage(),
    CreateTimeline(),
    ChatPage(),
  ];

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
            selectedItemColor: colorDark,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            currentIndex: currentIndex,
            enableFeedback: false,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(SolarIconsOutline.home),
                  label: 'Home',
                  activeIcon: Icon(SolarIconsBold.home)),
              BottomNavigationBarItem(
                  icon: Icon(HugeIcons.strokeRoundedSearch01), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(SolarIconsOutline.addSquare),
                label: 'Home',
                activeIcon: Icon(
                  SolarIconsBold.addSquare,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(SolarIconsOutline.bell),
                label: 'Home',
                activeIcon: Icon(
                  SolarIconsBold.bell,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(SolarIconsOutline.chatRoundCall),
                label: 'Home',
                activeIcon: Icon(
                  SolarIconsBold.chatRoundLine,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
