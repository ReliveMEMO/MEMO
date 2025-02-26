import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/textField.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Controllers for text fields
  final TextEditingController pageNameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController aboutUsController = TextEditingController();

  // Styling Colors
  final Color colorLight = const Color.fromARGB(255, 248, 240, 255);
  final Color colorDark = const Color(0xFF7f31c6);

  // Image and Error Text Variables
  File? _imageFile;
  String? pageNameErrorText;
  String? yearErrorText;
  String? aboutUsErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Page Name Field
            TextFieldComponent(
              hintText: "Page Name",
              obscureText: false,
              controller: pageNameController,
              errorText: pageNameErrorText,
              clearErrorText: () {
                setState(() {
                  pageNameErrorText = null;
                });
              },
            ),
            // Year Field
            TextFieldComponent(
              hintText: "Year (e.g. 2024/25)",
              obscureText: false,
              controller: yearController,
              errorText: yearErrorText,
              clearErrorText: () {
                setState(() {
                  yearErrorText = null;
                });
              },
            ),
            // About Us Field
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: colorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: aboutUsController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "About Us",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                  if (aboutUsErrorText != null)
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Text(
                        aboutUsErrorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
