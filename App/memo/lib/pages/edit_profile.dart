import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/dropDown.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Achievement {
  final String emoji;
  final String description;
  final String position;

  Achievement({required this.emoji, required this.description, required this.position});
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController gpacontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController gradyearcontroller = TextEditingController();

  String? avatarUrl;
  File? _imageFile;
  bool isLoading = true;
  final authService = AuthService();
  List<String> statusOptions = ['Level 3', 'Level 4', 'Level 5', 'Level 6', 'Alumni'];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('User_Info')
          .select()
          .eq('id', authService.getCurrentUserID() ?? '')
          .single();

      String fetchedStatus = response['user_level'] ?? 'Level 3';
      if (!statusOptions.contains(fetchedStatus)) {
        fetchedStatus = 'Level 3';
      }

      setState(() {
        fullNameController.text = response['full_name'] ?? '';
        birthDateController.text = response['birth_date'] ?? '';
        agecontroller.text = response['user_age']?.toString() ?? '';
        selectedStatus = fetchedStatus;
        gpacontroller.text = response['user_gpa']?.toString() ?? '';
        aboutController.text = response['user_about'] ?? '';
        avatarUrl = response['profile_pic'];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> updateUserProfile() async {
    try {
      int? age = int.tryParse(agecontroller.text);
      double? gpa = double.tryParse(gpacontroller.text);
      int? graduationYear = int.tryParse(gradyearcontroller.text);
      int currentYear = DateTime.now().year;

      if (age == null || age < 10 || age > 120) {
        showError("Age must be a number between 10 and 120.");
        return;
      }
      if (gpa == null || gpa < 0.0 || gpa > 4.0) {
        showError("GPA must be between 0.0 and 4.0.");
        return;
      }
      if (graduationYear == null || graduationYear > currentYear + 6) {
        showError("Graduation year cannot be more than 6 years from now.");
        return;
      }

      final updates = {
        'full_name': fullNameController.text,
        'birth_date': birthDateController.text,
        'user_age': age,
        'user_gpa': gpa,
        'user_grad_year': graduationYear,
        'user_about': aboutController.text,
        'user_level': selectedStatus,
        'profile_pic': avatarUrl,
      };

      await Supabase.instance.client
          .from('User_Info')
          .update(updates)
          .eq('id', authService.getCurrentUserID() ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      print("Error updating user profile: $e");
      showError("An error occurred while updating profile.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AvatarUpload(
                onImageSelected: (File? imageFile) {
                  setState(() {
                    _imageFile = imageFile;
                  });
                },
              ),
              CustomTextField(label: "Full Name", controller: fullNameController),
              DatePickerTextField(label: "BirthDate", controller: birthDateController),
              CustomTextField(label: "Age", controller: agecontroller),
              DropdownComponent(
                hintText: 'Student Status',
                items: statusOptions,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                selectedValue: selectedStatus,
              ),
              CustomTextField(label: "GPA", controller: gpacontroller),
              CustomTextField(label: "Graduation Year", controller: gradyearcontroller),
              CustomTextField(label: "About", controller: aboutController, maxLines: 3),
              const SizedBox(height: 20),
              const Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              AchievementsSection(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const CustomTextField(
      {required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class DatePickerTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const DatePickerTextField({required this.label, required this.controller});

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.day}.${picked.month}.${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: CustomTextField(label: label, controller: controller),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;

  const CustomDropdown(
      {required this.label, required this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 15),
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
              TextField(
                  controller: emojiController,
                  decoration:
                      const InputDecoration(labelText: "Emoji (e.g. 🔥)")),
              TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description")),
              TextField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: "Position")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
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
                Text(achievement.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(achievement.position,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        } else if (_achievements.length < _maxAchievements) {
          return GestureDetector(
            onTap: _addAchievement,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10)),
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
