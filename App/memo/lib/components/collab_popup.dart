import 'package:flutter/material.dart';
import 'package:memo/components/user_box.dart';

void showCustomPopup(BuildContext context) {
  // List of users
  List<String> users = [
    'User 1',
  ];

  showDialog(
    context: context,
    barrierDismissible: true, // Close the dialog when tapping outside
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
          onTap: () {}, // Prevent dialog from closing if tapping inside
          child: Container(
            width: 300,
            height: 400,
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserBox(
                  userId: users[index],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
