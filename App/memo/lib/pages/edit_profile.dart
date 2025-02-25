import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed background color to white
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              buildTextField("Full Name", "Thisas Ranchagoda"),
              buildTextField("BirthDate", "04.08.2003"),
              buildDropdownField("Programme", "Software Engineering"),
              buildDropdownField("Student Status", "Level 5"),
              buildTextArea("About", "Blah Blah Blah"),
              SizedBox(height: 20),
              Text(
                "Achievements",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  buildAchievement("IEEE Xtreme", "champions", Icons.whatshot),
                  buildAchievement("RCL'23", "participation", Icons.emoji_emotions),
                  buildAchievement("WebSpire", "volunteer", Icons.language),
                  buildAchievement("IEEE Xtreme", "champions", Icons.whatshot),
                  buildAchievement("RCL'23", "participation", Icons.emoji_emotions),
                  buildAddAchievement(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(label, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(label, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 16)),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextArea(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(label, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.all(16),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildAchievement(String title, String subtitle, IconData icon) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.orange),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget buildAddAchievement() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      
    );
  }
}
