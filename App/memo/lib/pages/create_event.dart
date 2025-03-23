import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/textField.dart';
import 'package:memo/pages/my_page.dart';
import 'package:memo/pages/page_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memo/services/auth_service.dart';

final authService = AuthService();

// Image and Error Text Variables
File? _imageFile;
String? avatarUrl;
String? pageNameErrorText;
String? yearErrorText;
String? aboutUsErrorText;

class CreateEvent extends StatefulWidget {
  final String pageId;
  const CreateEvent({super.key, required this.pageId});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  // Controllers for text fields
  final TextEditingController pageNameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController aboutUsController = TextEditingController();
  DateTime? selectedDate;

  // Styling Colors
  final Color colorLight = const Color.fromARGB(255, 248, 240, 255);
  final Color colorDark = const Color(0xFF7f31c6);

  final authService = AuthService();

  // Year Picker Function - Custom Year Selector

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

  Future<void> createEvent() async {
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
        final response = await Supabase.instance.client.from('events').insert({
          'admin': widget.pageId,
          'event_name': pageNameController.text,
          'Date': selectedDate?.toIso8601String(),
          'caption': aboutUsController.text,
          'cover': avatarUrl,
        });

        if (response == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event Created Successfully!')),
          );

          // Clear Fields after Successful Submission
          // pageNameController.clear();
          // yearController.clear();
          // aboutUsController.clear();
          // setState(() {
          //   _imageFile = null;
          // });

          // Navigate to Profile or Home Screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PageProfile(
                        userId: widget.pageId,
                      )));
        } else {
          print('Error: ${response?.message}');
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

  void selectDateTime(BuildContext context) async {
    // Select Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      // Select Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date and Time
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedDate = pickedDateTime;
          yearController.text =
              "${pickedDateTime.year}/${pickedDateTime.month}/${pickedDateTime.day} | ${pickedDateTime.hour}:${pickedDateTime.minute}"; // Update with full DateTime
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Avatar Upload Component
            SizedBox(height: 20),
            AvatarUpload(
              onImageSelected: (File? imageFile) {
                setState(() {
                  _imageFile = imageFile;
                });
              },
            ),
            // Page Name Field
            TextFieldComponent(
              hintText: "Event Name",
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
              onTap: () => selectDateTime(context),
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
                            : const Color.fromARGB(255, 135, 21, 158),
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
              onTap: createEvent,
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
                          'Create Event',
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
