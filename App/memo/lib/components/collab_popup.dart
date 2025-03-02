import 'package:flutter/material.dart';
import 'package:memo/components/user_box.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showCustomPopup(BuildContext context, String timelineId) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  // Fetch data
  final response = await Supabase.instance.client
      .from('Timeline_Table')
      .select()
      .eq('id', timelineId)
      .maybeSingle();

  // Close loading indicator
  Navigator.of(context).pop();

  // Extract users from response
  List<String> users = List<String>.from(response?['collaborators'] ?? []);
  final String admin = response?['admin'] as String;

  // Show the actual popup
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
                  isAdmin: users[index] == admin,
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
