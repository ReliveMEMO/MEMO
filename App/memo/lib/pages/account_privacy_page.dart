// Account Privacy Page
import 'package:flutter/material.dart';

class AccountPrivacyPage extends StatefulWidget {
  final bool initialIsPrivate;

  AccountPrivacyPage({required this.initialIsPrivate});

  @override
  _AccountPrivacyPageState createState() => _AccountPrivacyPageState();
}

class _AccountPrivacyPageState extends State<AccountPrivacyPage> {
  late bool isPrivate;

  @override
  void initState() {
    super.initState();
    isPrivate = widget.initialIsPrivate;
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
                onChanged: (value) {
                  setState(() {
                    isPrivate = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
