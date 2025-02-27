import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/textField.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/auth_service.dart';

final authService = AuthService();

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

  Future<void> uploadImage() async {
    if (_imageFile == null) {
      return;
    }

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'page-images/$fileName';

      // Upload Image to Supabase Storage
      await Supabase.instance.client.storage
          .from('page-images')
          .upload(path, _imageFile!);

      // Get Public URL of the Uploaded Image
      final url = Supabase.instance.client.storage
          .from('page-images')
          .getPublicUrl(path);

      avatarUrl = url;
    } catch (e) {
      print('Image Upload Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
    }
  }

  // Image and Error Text Variables
  File? _imageFile;
  String? avatarUrl;
  String? pageNameErrorText;
  String? yearErrorText;
  String? aboutUsErrorText;

  void _validateFields() {
    setState(() {
      pageNameController.text.isEmpty
          ? pageNameErrorText = 'Please enter the page name'
          : pageNameErrorText = null;
      yearController.text.isEmpty
          ? yearErrorText = 'Please enter the year (e.g. 2024/25)'
          : yearErrorText = null;
      aboutUsController.text.isEmpty
          ? aboutUsErrorText = 'Please provide a short description'
          : aboutUsErrorText = null;
    });
  }

  Future<void> createPage() async {
    // Get Current User ID
    final userId = authService.getCurrentUserID();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to create a page')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Validate Fields
    _validateFields();
    if (pageNameErrorText == null &&
        yearErrorText == null &&
        aboutUsErrorText == null) {
      try {
        // Upload Image (if selected)
        await uploadImage();

        // Insert Page Data into Supabase
        final response = await Supabase.instance.client.from('Pages').insert({
          'user_id': userId,
          'page_name': pageNameController.text,
          'year': yearController.text,
          'about_us': aboutUsController.text,
          'image_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Page Created Successfully!')),
          );

          // Clear Fields after Successful Submission
          pageNameController.clear();
          yearController.clear();
          aboutUsController.clear();
          setState(() {
            _imageFile = null;
          });

          // Navigate to Profile or Home Screen
          Navigator.pushNamed(context, '/profile');
        } else {
          print('Error: ${response.error!.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.error!.message}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar Upload Component
            AvatarUpload(
              onImageSelected: (File? imageFile) {
                setState(() {
                  _imageFile = imageFile;
                });
              },
            ),
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
                      style: TextStyle(color: colorDark),
                      decoration: InputDecoration(
                        hintText: "About Us",
                        hintStyle: TextStyle(color: const Color(0xFF7f31c6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(10),
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
            // Create Page Button
            GestureDetector(
              onTap: createPage,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: colorDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Page',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 17)
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
