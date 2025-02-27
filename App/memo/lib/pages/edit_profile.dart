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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: _imageFile == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.purple,
                        child: Icon(Icons.add, color: Colors.white, size: 15),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFieldComponent(
              hintText: "Full Name",
              obscureText: false,
              controller: fullnameController,
              backgroundColor: Colors.grey.shade300,
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      birthDate == null
                          ? 'Select Birthdate'
                          : DateFormat('dd.MM.yyyy').format(birthDate!),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownComponent(
              hintText: 'Programme',
              items: const ['Software Engineering', 'Computer Science', 'AI and Data Science', 'Business Information Systems'],
              onChanged: (value) => setState(() => selectedProgram = value),
              selectedValue: selectedProgram,
            ),
            DropdownComponent(
              hintText: 'Student Status',
              items: const ['Level 3', 'Level 4', 'Level 5', 'Level 6', 'Alumni'],
              onChanged: (value) => setState(() => selectedStatus = value),
              selectedValue: selectedStatus,
            ),
            TextFieldComponent(
              hintText: "About",
              obscureText: false,
              controller: aboutController,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade100,
              ),
              child: Column(
                children: [
                  const Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildAchievementCard("IEEE Xtreme", "champions", Icons.whatshot),
                      _buildAchievementCard("RCL'23", "participation", Icons.emoji_people),
                      _buildAchievementCard("WebSpire", "volunteer", Icons.web),
                      _buildAchievementCard("IEEE Xtreme", "champions", Icons.whatshot),
                      _buildAchievementCard("RCL'23", "participation", Icons.emoji_people),
                      _buildAchievementCard("Add Achievement", "", Icons.add, addNew: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(String title, String subtitle, IconData icon, {bool addNew = false}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 2)],
      ),
      child: Column(
        children: [
          Icon(icon, color: addNew ? Colors.black54 : Colors.orange, size: 30),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
