import 'package:flutter/material.dart';
import 'package:memo/components/achievements_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/auth_service.dart';

class bio_section extends StatefulWidget {
  final PostgrestMap? userDetails;

  const bio_section({super.key, required this.userDetails});

  @override
  _BioSectionState createState() => _BioSectionState();
}

class _BioSectionState extends State<bio_section> {
  String major = "";
  String gradYear = "";
  String age = "";
  String gpa = "";
  String about = "";
  List<Map<String, String>> achievements = [];

  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    updateStats();
  }

  void updateStats() {
    setState(() {
      major = widget.userDetails!["programme"] as String;
      gradYear = widget.userDetails!["user_grad_year"].toString();
      age = widget.userDetails!["user_age"].toString();
      gpa = widget.userDetails!["user_gpa"].toString();
      about = widget.userDetails!["user_about"] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Adjust alignment of the entire column
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center, // Center align the major text box
          child: _buildStackedTextBox("Major", major, width: 320),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Adjust alignment of row items
          children: [
            _buildStackedTextBox("Grad Year", gradYear),
            _buildStackedTextBox("Age", age),
            _buildStackedTextBox("GPA", gpa),
          ],
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center, // Center align the about text box
          child: _buildStackedTextBox("About", about, width: 320, height: 50),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center, // Center align the achievements section
          child: _buildAchievementsSection(),
        ),
      ],
    );
  }

  Widget _buildStackedTextBox(String label, String value,
      {double width = 90, double? height}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: height ?? 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 5), // Adjust the top padding as needed
            child: Align(
              alignment: Alignment.center, // Adjust alignment if necessary
              child: Text(
                value,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
          top: -12,
          left: width / 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -15,
            left: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white,
              child: const Text("Achievements",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ),
          ),
          AchievementsSection(
            userId: widget.userDetails?["id"],
            editable: false,
          )
        ],
      ),
    );
  }
}
