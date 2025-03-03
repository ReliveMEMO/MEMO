import 'package:flutter/material.dart';
import 'package:memo/pages/account_privacy_page.dart';
import 'package:memo/pages/about_us_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isPrivate = false;

  Future<void> _launchWebsite() async {
    const url = 'https://www.relivememo.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Log Out"),
        content: Text("Are you sure you want to log out of your MEMO account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Implement actual logout logic here
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildPrivacyOption(),
                  Divider(),
                  _buildAboutUsOption(),
                  Divider(),
                  _buildContactUsOption(),
                  Divider(),
                  _buildLogoutOption(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: Text(
                  "© 2024 MEMO. All Rights Reserved",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption() => ListTile(
        leading: Icon(Icons.lock, color: Colors.black),
        title: Text("Account privacy", style: TextStyle(fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isPrivate ? "Private" : "Public"),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
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
          if (result != null) setState(() => isPrivate = result);
        },
      );

  Widget _buildAboutUsOption() => ListTile(
        leading: Icon(Icons.info_outline, color: Colors.black),
        title: Text("About Us", style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        ),
      );

  Widget _buildContactUsOption() => ListTile(
        leading: Icon(Icons.mail_outline, color: Colors.black),
        title: Text("Contact Us", style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _launchWebsite,
      );

  Widget _buildLogoutOption() => ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title:
            Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16)),
        onTap: _showLogoutConfirmation,
      );
}
