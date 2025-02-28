import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/textField.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/auth_service.dart';

final authService = AuthService();

// Image and Error Text Variables
File? _imageFile;
String? avatarUrl;
String? pageNameErrorText;
String? yearErrorText;
String? aboutUsErrorText;

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

  final authService = AuthService();

  // Year Picker Function - Custom Year Selector
  Future<void> _selectYear(BuildContext context) async {
    int selectedYear = DateTime.now().year;
    int startYear = 1900;
    int endYear = 2025;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Year',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          backgroundColor: const Color.fromARGB(255, 246, 244, 247),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns for grid
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2,
              ),
              itemCount: endYear - startYear + 1,
              itemBuilder: (BuildContext context, int index) {
                int year = startYear + index;
                bool isSelected = year.toString() == yearController.text;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      yearController.text = year.toString();
                      yearErrorText = null;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 131, 67, 195)
                          : const Color.fromARGB(0, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? colorLight
                            : const Color.fromARGB(255, 0, 0, 0),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

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

  void _validateFields() {
    setState(() {
      pageNameController.text.isEmpty
          ? pageNameErrorText = 'Please enter the page name'
          : pageNameErrorText = null;
      yearController.text.isEmpty
          ? yearErrorText = 'Please select a year'
          : yearErrorText = null;
      aboutUsController.text.isEmpty
          ? aboutUsErrorText = 'Please provide a short description'
          : aboutUsErrorText = null;
    });
  }

  Future<void> createPage() async {
    // Get Current User ID
    final userId = authService.getCurrentUserID();

    // Validate Fields
    _validateFields();
    if (pageNameErrorText == null &&
        yearErrorText == null &&
        aboutUsErrorText == null) {
      try {
        // Upload Image (if selected)
        await uploadImage();

        // Insert Page Data into Supabase
        final response =
            await Supabase.instance.client.from('page_table').insert({
          'admin': authService.getCurrentUserID(),
          'page_name': pageNameController.text,
          'year': yearController.text,
          'about_us': aboutUsController.text,
          'image_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (response == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Page Created Successfully!')),
          );

          // Clear Fields after Successful Submission
          // pageNameController.clear();
          // yearController.clear();
          // aboutUsController.clear();
          // setState(() {
          //   _imageFile = null;
          // });

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

            // Year Picker Field
            GestureDetector(
              onTap: () => _selectYear(context),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colorLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        yearErrorText != null ? Colors.red : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      yearController.text.isEmpty
                          ? 'Started Year (e.g. 2024)'
                          : 'Year: ${yearController.text}',
                      style: TextStyle(
                        color: yearController.text.isEmpty
                            ? const Color.fromARGB(255, 167, 107, 219)
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: colorDark),
                  ],
                ),
              ),
            ),
            if (yearErrorText != null)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  yearErrorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.start,
                ),
              ),

            // About Us Field using TextFieldComponent
            TextFieldComponent(
              hintText: "About Us",
              obscureText: false,
              controller: aboutUsController,
              errorText: aboutUsErrorText,
              clearErrorText: () {
                setState(() {
                  aboutUsErrorText = null;
                });
              },
              maxLines: 7, // Multiline Support
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
