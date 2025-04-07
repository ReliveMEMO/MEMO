import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Achievement {
  final String emoji;
  final String description;
  final String position;
  final String id;

  Achievement(
      {required this.emoji,
      required this.description,
      required this.position,
      this.id = ''});
}

class AchievementsSection extends StatefulWidget {
  final bool editable;
  final String userId;
  const AchievementsSection(
      {Key? key, required this.userId, this.editable = false})
      : super(key: key);

  @override
  _AchievementsSectionState createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  final List<Achievement> _achievements = [];
  final int _maxAchievements = 6;
  final emojiController = TextEditingController();
  final descriptionController = TextEditingController();
  final positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAchievements();
  }

  Future<void> fetchAchievements() async {
    final response = await Supabase.instance.client
        .from('achievements')
        .select()
        .eq('user_id', widget.userId)
        .order('created_at', ascending: false)
        .limit(6);

    if (response != null) {
      setState(() {
        _achievements.clear();
        for (var row in response) {
          _achievements.add(Achievement(
            id: row['id'] as String,
            emoji: row['emoji'] as String,
            description: row['description'] as String,
            position: row['position'] as String,
          ));
        }
      });
    }
  }

  Future<void> insertAchievement() async {
    final response =
        await Supabase.instance.client.from('achievements').insert([
      {
        'user_id': widget.userId,
        'emoji': emojiController.text,
        'description': descriptionController.text,
        'position': positionController.text,
      },
    ]);

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!.message)),
      );
    } else {
      fetchAchievements();
    }
  }

  Future<void> deleteAchievements(String acID) async {
    final response = await Supabase.instance.client
        .from('achievements')
        .delete()
        .eq('id', acID);

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!.message)),
      );
    } else {
      fetchAchievements();
    }
  }

  void _addAchievement() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Achievement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(labelText: "Emoji (e.g. 🔥)"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: "Position"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (emojiController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    positionController.text.isNotEmpty) {
                  setState(() {
                    if (_achievements.length < _maxAchievements) {
                      _achievements.add(Achievement(
                        emoji: emojiController.text,
                        description: descriptionController.text,
                        position: positionController.text,
                      ));
                      insertAchievement();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        GridView.builder(
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
              return GestureDetector(
                onLongPress: () {
                  if (widget.editable) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Achievement"),
                          content: const Text(
                              "Are you sure you want to delete this achievement?"),
                          backgroundColor: Colors.white,
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _achievements.removeAt(index);
                                });
                                Navigator.of(context).pop();
                                deleteAchievements(achievement.id);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(achievement.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 5),
                      Text(
                        achievement.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3), // Space between elements
                      Text(
                        achievement.position,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            } else if (_achievements.length < _maxAchievements &&
                widget.editable) {
              return GestureDetector(
                onTap: _addAchievement,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
