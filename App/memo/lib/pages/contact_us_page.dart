import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String email = "relivememo@gmail.com";
  final String phone = "+94 77 951 8001";

  // Function to copy text to clipboard
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$text copied to clipboard")),
    );
  }

  // Function to launch email app
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // Function to launch phone dialer
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact Us")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Colors.black),
              title: Text("E-mail"),
              subtitle: Text(email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.grey),
                    onPressed: () => _copyToClipboard(context, email),
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new, color: Colors.grey),
                    onPressed: _launchEmail,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.black),
              title: Text("Phone"),
              subtitle: Text(phone),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.grey),
                    onPressed: () => _copyToClipboard(context, phone),
                  ),
                  IconButton(
                    icon: Icon(Icons.phone_forwarded, color: Colors.grey),
                    onPressed: _launchPhone,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
