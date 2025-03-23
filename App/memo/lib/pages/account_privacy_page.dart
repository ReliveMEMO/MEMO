// Account Privacy Page
import 'package:flutter/material.dart';
import 'package:memo/pages/create_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPrivacyPage extends StatefulWidget {
  final bool initialIsPrivate;

  AccountPrivacyPage({required this.initialIsPrivate});

  @override
  _AccountPrivacyPageState createState() => _AccountPrivacyPageState();
}

class _AccountPrivacyPageState extends State<AccountPrivacyPage> {
  late bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    final response = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq('id', authService.getCurrentUserID()!);
    if (response != null) {
      setState(() {
        isPrivate = response[0]['private_profile'];
      });
      print(isPrivate);
    }
  }

  Future<bool> _showConfirmationDialog(bool newValue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Make account ${newValue ? 'Private' : 'Public'}?"),
        content: Text(newValue
            ? "Only your followers will be able to see your posts and interact with your content. Your existing followers will remain."
            : "Your posts and content will be visible to anyone on MEMO."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm"),
          ),
        ],
      ),
    );

    return confirmed ?? false; // Return false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isPrivate);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Account privacy", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Private account",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                    SizedBox(height: 5),
                    Text(
                      "When your account is public, your profile and posts can be seen by anyone, even if they don't have an account.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPrivate,
                onChanged: (newValue) async {
                  final confirmed = await _showConfirmationDialog(newValue);
                  if (confirmed == true) {
                    setState(() => isPrivate = newValue);
                    final response = await Supabase.instance.client
                        .from('User_Info')
                        .update({'private_profile': isPrivate}).eq(
                            'id', authService.getCurrentUserID()!);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
