import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
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
  String? ageError;
  String? gpaError;
  String? gradYearError;
  bool isLoading = true;
   final authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    

    

    final response = await Supabase.instance.client
        .from('User_info')
        .select()
        .eq('user_id', authService.getCurrentUserID() ?? '')
        .single();

    if (response != null) {
      setState(() {
        fullNameController.text = response['full_name'] ?? '';
        birthDateController.text = response['birth_date'] ?? '';
        agecontroller.text = response['age']?.toString() ?? '';
        gpacontroller.text = response['gpa']?.toString() ?? '';
        gradyearcontroller.text = response['grad_year']?.toString() ?? '';
        aboutController.text = response['about'] ?? '';
        avatarUrl = response['avatar_url'];
        isLoading = false;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) {
      avatarUrl =
          'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/default.jpg';
      return;
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    await Supabase.instance.client.storage
        .from('profile-pictures')
        .upload(path, _imageFile!);

    final url = await Supabase.instance.client.storage
        .from('profile-pictures')
        .getPublicUrl(path);

    avatarUrl = url;
  }
  void validateAge() {
    final age = int.tryParse(agecontroller.text);
    if (age == null || age < 0 || age > 120) {
      setState(() {
        ageError = "Please enter a valid age.";
      });
    } else {
      setState(() {
        ageError = null;
      });
    }
  }

  void validateGpa() {
    final gpa = double.tryParse(gpacontroller.text);
    if (gpa == null || gpa < 0 || gpa > 4) {
      setState(() {
        gpaError = "Please enter a valid gpa.";
      });
    } else {
      setState(() {
        gpaError = null;
      });
    }
  }

  void validateGradYear() {
  final gradYear = int.tryParse(gradyearcontroller.text);
  final currentYear = DateTime.now().year;

  if (gradYear == null || gradYear < currentYear || gradYear > currentYear + 15) {
    setState(() {
      gradYearError = "Enter a valid graduation year ($currentYear - ${currentYear + 6}).";
    });
  } else {
    setState(() {
      gradYearError = null;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
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
              CustomTextField(label: "Age", controller: agecontroller, errorText: ageError, onChanged: (value) => validateAge()),
              CustomDropdown(
                label: "Programme",
                value: "Software Engineering",
                items: ["Software Engineering", "Computer Science", "AI and Data Science", "Business Information Systems"],
              ),
              CustomDropdown(
                label: "Student Status",
                value: "Level 5",
                items: ["Level 3", "Level 4", "Level 5", "Level 6",  "Alumni"],
              ),
              CustomTextField(label: "GPA", controller: gpacontroller, errorText: gpaError, onChanged: (value) => validateGpa()),
              CustomTextField(label: "Graduation Year", controller: gradyearcontroller, errorText: gradYearError, onChanged: (value) => validateGradYear()),
              CustomTextField(label: "About", controller: aboutController, maxLines: 3),
              SizedBox(height: 20),
              Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              AchievementsSection(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle update profile action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white // Button color
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
  final String? errorText;
  final Function(String)? onChanged;

  const CustomTextField({required this.label, required this.controller, this.maxLines = 1, this.errorText, this.onChanged});

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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: errorText != null ? BorderSide(color: Colors.red) : BorderSide.none),
            errorText: errorText,
          ),
          onChanged: onChanged,
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

  const CustomDropdown({required this.label, required this.value, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (val) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
