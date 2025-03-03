import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About MEMO"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MEMO – Relive Every Vibe! 🚀✨",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "MEMO is a collaborative social media platform designed for university students and alumni "
              "to preserve, share, and relive memories through interactive timelines.",
              textAlign: TextAlign.justify, // Moved outside TextStyle
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Why MEMO?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Unlike other platforms, MEMO focuses on group memory sharing rather than short-lived interactions.",
              textAlign: TextAlign.justify, // Moved outside TextStyle
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Key Features:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 9),
            _buildFeatureItem(
                "•Personalized Timelines – Organize & revisit life moments."),
            _buildFeatureItem(
                "•Collaborative Memory Sharing – Friends contribute to shared timelines "),
            _buildFeatureItem(
                "•Event Notifications – Stay updated on important events."),
            _buildFeatureItem(
                "•Memory Reminders – Never forget a special moment."),
            _buildFeatureItem(
                "•Detailed Profiles – Showcase your journey & achievements."),
            SizedBox(height: 24),
            Text(
              "Development Team",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTeamMember(name: "Sandinu Pinnawala"),
            _buildTeamMember(name: "Sachin Kulathilaka"),
            _buildTeamMember(name: "Thisas Ranchagoda"),
            _buildTeamMember(name: "Malsha Jayasinghe"),
            _buildTeamMember(name: "Monali Suriarachchi"),
            _buildTeamMember(name: "Sadinsa Welagedara"),
            SizedBox(height: 30),
            Text(
              "Reconnect, reminisce, and relive every vibe with MEMO! 🎉",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify, // Moved outside TextStyle
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTeamMember({required String name, String? imagePath}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
