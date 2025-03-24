import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo/components/avatar_upload.dart';
import 'package:memo/components/dropDown.dart';
// import 'package:memo/components/nav_bar.dart';
import 'package:memo/components/textField.dart';
import 'package:intl/intl.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final authService = AuthService();
  String? selectedProgram;
  String? selectedStatus;
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController iitIdController = TextEditingController();
  DateTime? birthDate;
  final Color colorLight = const Color.fromARGB(255, 248, 240, 255);
  final Color colorDark = const Color(0xFF7f31c6);
  String? avatarUrl;
  File? _imageFile;
  String? fullnameErrorText;
  String? iitIdErrorText;
  String? dateErrorText;
  String? programmeErrorText;
  String? statusErrorText;
  File? _selectedImage;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: birthDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: colorLight,
                    onPrimary: colorDark,
                    surface: colorDark,
                    onSurface: colorLight,
                  ),
                  dialogBackgroundColor: colorDark),
              child: child!);
        });
    if (picked != null && picked != birthDate) {
      setState(() {
        birthDate = picked;
        dateErrorText = null; // Clear error text when a date is selected
      });
    }
  }

  Future<void> createProfile() async {
    try {
      _validateFields();
      await uploadImage();

      final userId = authService.getCurrentUserID();
      final displayName = authService.getCurrentUser();

      final response = await Supabase.instance.client.from('User_Info').insert({
        'id': userId,
        'full_name': fullnameController.text,
        'iit_id': iitIdController.text,
        'birth_date': birthDate?.toIso8601String(),
        'programme': selectedProgram,
        'status': selectedStatus,
        'profile_pic': avatarUrl,
        'display_name': displayName
      });
      print(response);
      Navigator.pushNamed(context, '/my-page');
    } catch (e) {
      print(e);
    }
  }

  void _validateFields() {
    setState(() {
      fullnameController.text.isEmpty
          ? fullnameErrorText = 'Please fill this field'
          : fullnameErrorText = null;
      iitIdController.text.isEmpty
          ? iitIdErrorText = 'Please fill this field'
          : iitIdErrorText = null;
      birthDate == null
          ? dateErrorText = 'Please select a date'
          : dateErrorText = null;
      selectedProgram == null
          ? programmeErrorText = 'Please select a programme'
          : programmeErrorText = null;
      selectedStatus == null
          ? statusErrorText = 'Please select a status'
          : statusErrorText = null;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

      if (image != null) {
        final int cropSize =
            image.width < image.height ? image.width : image.height;
        final int offsetX = (image.width - cropSize) ~/ 2;
        final int offsetY = (image.height - cropSize) ~/ 2;
        final img.Image croppedImage = img.copyCrop(image,
            x: offsetX, y: offsetY, width: cropSize, height: cropSize);

        // Resize the cropped image to 500x500
        final img.Image resizedImage =
            img.copyResize(croppedImage, width: 1000, height: 1000);
        final File compressedImage = File(pickedImage.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage));

        setState(() {
          _selectedImage = compressedImage;
        });
      }
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) {
      avatarUrl =
          'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/default.jpg';
      return;
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    await Supabase.instance.client.storage
        .from('profile-pictures')
        .upload(path, _selectedImage!);

    final url = await Supabase.instance.client.storage
        .from('profile-pictures')
        .getPublicUrl(path);

    avatarUrl = url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: NavBar(),
      appBar: AppBar(
        title: Text("Create Profile ${authService.getCurrentUser()}"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: colorDark,
            backgroundImage:
                _selectedImage != null ? FileImage(_selectedImage!) : null,
            child: _selectedImage == null
                ? GestureDetector(
                    onTap: _pickImage,
                    child: Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          SizedBox(
            height: 10,
          ),
          TextFieldComponent(
            hintText: "Full Name",
            obscureText: false,
            controller: fullnameController,
            // borderRadius: 10,
            errorText: fullnameErrorText,
            clearErrorText: () {
              setState(() {
                fullnameErrorText = null;
              });
            },
          ),
          TextFieldComponent(
            hintText: "IIT ID",
            obscureText: false,
            controller: iitIdController,
            errorText: iitIdErrorText,
            // borderRadius: 10,
            clearErrorText: () {
              setState(() {
                iitIdErrorText = null;
              });
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: colorLight,
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                        color: dateErrorText != null
                            ? Colors.red
                            : Colors.transparent),
                  ),
                  child: ListTile(
                    title: Text(
                      birthDate == null
                          ? 'Select Birthdate'
                          : 'Birthdate: ${DateFormat.yMd().format(birthDate!)}',
                      style: TextStyle(color: colorDark),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: colorDark,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                if (dateErrorText != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      dateErrorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.start,
                    ),
                  ),
              ],
            ),
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
            errorText: programmeErrorText,
            clearErrorText: () {
              setState(() {
                programmeErrorText = null;
              });
            },
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
                selectedStatus = value;
              });
            },
            selectedValue: selectedStatus,
            errorText: statusErrorText,
            clearErrorText: () {
              setState(() {
                statusErrorText = null;
              });
            },
          ),
          GestureDetector(
            onTap: createProfile,
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
                        'Create Profile',
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
          )
        ],
      ),
    );
  }
}
