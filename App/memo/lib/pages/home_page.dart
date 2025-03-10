import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:memo/pages/profile_page.dart';
import 'package:memo/providers/user_provider.dart';

import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UserProvider>(context).userDetails;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.10,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: screenHeight * 0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/TextLogo.png',
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfilePage();
                    }));
                  },
                  child: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: userDetails?['profile_pic'] as String? ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}