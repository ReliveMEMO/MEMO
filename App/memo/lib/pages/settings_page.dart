// Settings Page
import 'package:flutter/material.dart';
import 'package:memo/pages/account_privacy_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: Colors.black),
              title: Text("Account privacy",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isPrivate ? "Private" : "Public",
                      style: TextStyle(color: Colors.black)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.black54),
                ],
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AccountPrivacyPage(initialIsPrivate: isPrivate),
                  ),
                );
                if (result != null) {
                  setState(() {
                    isPrivate = result;
                  });
                }
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
