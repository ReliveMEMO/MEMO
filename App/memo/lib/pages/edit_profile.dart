import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/dropDown.dart';
import 'package:memo/components/textField.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final authService = AuthService();
  String? selectedProgram;
  String? selectedStatus;
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  DateTime? birthDate;
  final Color colorLight = const Color(0xFFBDBDBD);
  final Color colorDark = const Color(0xFF7f31c6);
  String? avatarUrl;
  File? _imageFile;
  String? fullnameErrorText;
  String? dateErrorText;
  String? programmeErrorText;
  String? statusErrorText;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthDate) {
      setState(() {
        birthDate = picked;
        dateErrorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AvatarUpload(
                onImageSelected: (File? imageFile) {
                  setState(() {
                    _imageFile = imageFile;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            buildHeading("BirthDate"),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 12),
                  margin: const EdgeInsets.only(right: 15), // Adjust margin to move right
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: dateErrorText != null ? Colors.red : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    birthDate == null
                        ? 'Select Birthdate'
                        : DateFormat('dd.MM.yyyy').format(birthDate!),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ),
            if (dateErrorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  dateErrorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 10),
            buildInputField("Full Name", "Sandinu Pinnawala"),
            buildDropdownField("Programme", "Software Engineering", ["Software Engineering", "Computer Science"], (String? newValue) {
              setState(() {
                selectedProgram = newValue;
              });
            }),
            buildDropdownField("Student Status", "Level 5", ["Level 5", "Level 6"], (String? newValue) {
              setState(() {
                selectedStatus = newValue;
              });
            }),
            buildTextArea("About", "Blah Blah Blah"),
            const SizedBox(height: 20),
            Text(
              "Achievements",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            buildAchievementsGrid(),
          ],
        ),
      ),
    );
  }



Widget buildInputField(String label, String value, {double height = 25}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: height, 
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: value),
              readOnly: true,
              maxLines: null, 
            ),
          ),
        ),
      ],
    ),
  );
}


  

Widget buildDropdownField(String label, String value, List<String> options, void Function(String?) onChanged, {double height = 50}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: height, // Set desired height
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                items: options.map((String option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                icon: Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget buildTextArea(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: value),
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAchievementsGrid() {
    List<Map<String, String>> achievements = [
      {"icon": "🔥", "text": "IEEE Xtreme\nchampions"},
      {"icon": "😊", "text": "RCL'23\nparticipation"},
      {"icon": "🕸", "text": "WebSpire\nvolunteer"},
      {"icon": "🔥", "text": "IEEE Xtreme\nchampions"},
      {"icon": "😊", "text": "RCL'23\nparticipation"},
      {"icon": "➕", "text": "add\nachievement"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievements[index]['icon']!,
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 5),
              Text(
                achievements[index]['text']!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
      ),
    );
  }
}