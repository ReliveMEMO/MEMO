import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memo/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDetails = userProvider.userDetails;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.04), // Adjust height based on screen size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/TextLogo.png',
                  width: screenWidth * 0.2, // Adjust width based on screen size
                  height: screenWidth * 0.2, // Adjust height based on screen size
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: CircleAvatar(
                  radius: screenWidth * 0.08, // Adjust radius based on screen size
                  backgroundImage: userDetails?['profile_pic'] != null
                      ? CachedNetworkImageProvider(userDetails?['profile_pic'])
                      : AssetImage('assets/images/default_profile.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}