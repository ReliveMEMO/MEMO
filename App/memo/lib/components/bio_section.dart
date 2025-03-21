import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/auth_service.dart';

class bio_section extends StatefulWidget {
  const bio_section({super.key});

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
    fetchUserBio();
  }

  Future<void> fetchUserBio() async {
    try {
      final response = await Supabase.instance.client
          .from('User_Info')
          .select()
          .eq('id', authService.getCurrentUserID() ?? '')
          .single();

      setState(() {
        major = response['user_major'] ?? "BEng. Software Engineering";
        gradYear = response['user_grad_year']?.toString() ?? "2027";
        age = response['user_age']?.toString() ?? "21";
        gpa = response['user_gpa']?.toString() ?? "3.0";
        about = response['user_about'] ?? "blah blah blah blah";
        
      });
    } catch (e) {
      print("Error fetching bio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Adjust alignment of the entire column
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center, // Center align the major text box
          child: _buildStackedTextBox("Major", major, width: 320),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust alignment of row items
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

  Widget _buildStackedTextBox(String label, String value, {double width = 90, double? height}) {
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
            padding: const EdgeInsets.only(top: 5), // Adjust the top padding as needed
            child: Align(
              alignment: Alignment.center, // Adjust alignment if necessary
              child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
          ),
          Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: achievements.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievements[index]["emoji"]!,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        achievements[index]["description"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
