import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/dropDown.dart';
import 'package:memo/components/textField.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  String? selectedProgram;
  final TextEditingController fullnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const AvatarUpload(),
          TextFieldComponent(
            hintText: "Full Name",
            obscureText: false,
            controller: fullnameController,
          ),
          DropdownComponent(
            hintText: ' Programme',
            items: const [
              'Software Engineering',
              'Computer Science',
              'AI and Data Science',
              'Business Information Systems'
            ], // Dropdown options
            onChanged: (value) {
              setState(() {
                selectedProgram = value;
              });
            },
            selectedValue: selectedProgram,
          ),
          DropdownComponent(
            hintText: ' Student Status',
            items: const [
              'Level 3',
              'Level 4',
              'Level 5',
              'Level 6',
              'Alumni'
            ], // Dropdown options
            onChanged: (value) {
              setState(() {
                selectedProgram = value;
              });
            },
            selectedValue: selectedProgram,
          ),
        ],
      ),
    );
  }
}
