import 'package:flutter/material.dart';

class bio_section extends StatelessWidget {
  const bio_section({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              // Major Section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    ),
                    child: Text(
                      "BEng. Software Engineering",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    left: 130,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      child: Text(
                        "Major",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Grad Year, Age, GPA Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Grad Year
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 90,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(
                            "2027",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 15,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Text(
                            "Grad Year",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Age
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 90,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(
                            "21",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 25,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Text(
                            "Age",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // GPA
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 90,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(
                            "3.0",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 30,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white,
                          child: Text(
                            "GPA",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              // About Section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 320,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "blah blah blah blah\nblah blah blah blah",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -12,
                    left: 130,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      child: Text(
                        "About",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Achievements Section
              AchievementsSection(),
            ],
          ),
        ),
      ],
    );
  }
}

class AchievementsSection extends StatefulWidget {
  const AchievementsSection({Key? key}) : super(key: key);

  @override
  _AchievementsSectionState createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  final List<Achievement> _achievements = [];
  final int _maxAchievements = 6;

  void _addAchievement() {
    showDialog(
      context: context,
      builder: (context) {
        final emojiController = TextEditingController();
        final descriptionController = TextEditingController();
        final positionController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Achievement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emojiController, decoration: const InputDecoration(labelText: "Emoji (e.g. 🔥)")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: positionController, decoration: const InputDecoration(labelText: "Position")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                if (emojiController.text.isNotEmpty && descriptionController.text.isNotEmpty && positionController.text.isNotEmpty) {
                  setState(() {
                    if (_achievements.length < _maxAchievements) {
                      _achievements.add(Achievement(
                        emoji: emojiController.text,
                        description: descriptionController.text,
                        position: positionController.text,
                      ));
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _achievements.length + 1,
      itemBuilder: (context, index) {
        if (index < _achievements.length) {
          final achievement = _achievements[index];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 5),
                Text(achievement.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(achievement.position, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        } else if (_achievements.length < _maxAchievements) {
          return GestureDetector(
            onTap: _addAchievement,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, color: Colors.grey),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class Achievement {
  final String emoji;
  final String description;
  final String position;

  Achievement({
    required this.emoji,
    required this.description,
    required this.position,
  });
}
