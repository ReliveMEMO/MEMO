import "dart:io";

import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:image_picker/image_picker.dart";
import "package:memo/components/user_search.dart";
import "package:memo/services/auth_service.dart";
import "package:solar_icons/solar_icons.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import 'package:image/image.dart' as img;

class CreateTimeline extends StatefulWidget {
  const CreateTimeline({super.key});

  @override
  State<CreateTimeline> createState() => _CreateTimelineState();
}

class _CreateTimelineState extends State<CreateTimeline> {
  final authService = AuthService();
  final TextEditingController timelineNameController = TextEditingController();
  final TextEditingController timelineDescriptionController =
      TextEditingController();
  File? _image;
  String? avatarUrl;
  String? timelineNameError;
  List<String> collaborators = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      final img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

      if (image != null) {
        final img.Image resizedImage =
            img.copyResize(image, width: 500, height: 500);
        final File compressedImage = File(pickedImage.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage));

        setState(() {
          _image = compressedImage;
        });
      }
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) {
      avatarUrl =
          'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/profile-pictures/uploads/default.jpg';
      return;
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    await Supabase.instance.client.storage
        .from('timeline_covers')
        .upload(path, _image!);

    final url = await Supabase.instance.client.storage
        .from('timeline_covers')
        .getPublicUrl(path);

    avatarUrl = url;
  }

  Future<void> createTimeLIne() async {
    try {
      _validateFields();
      await uploadImage();

      final userId = authService.getCurrentUserID();

      final response =
          await Supabase.instance.client.from('Timeline_Table').insert({
        'id': userId,
        'timeline_name': timelineNameController.text,
        'timeLine_Description': timelineDescriptionController.text,
        'timeline_Cover': avatarUrl,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'lastUpdate': DateTime.now().toUtc().toIso8601String(),
        'admin': userId,
        'collaborators': collaborators,
      });
      print(response);
      Navigator.pushNamed(context, '/my-page');
    } catch (e) {
      print(e);
    }
  }

  void _validateFields() {
    setState(() {
      timelineNameController.text.isEmpty
          ? timelineNameError = 'Please fill this field'
          : timelineNameError = null;
    });
  }

  void _showUserSearchPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return UserSearch(
          onUsersSelected: (selectedUsers) {
            setState(() {
              collaborators = selectedUsers;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color colorLight = const Color.fromARGB(255, 248, 240, 255);
    final Color colorDark = const Color(0xFF7f31c6);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Timeline'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            children: [
              const Text(
                'TimeLine Name',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
              SizedBox(height: 8),
              TextField(
                controller: timelineNameController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  fillColor: Colors.grey[200],
                  filled: true,
                  hintText: "Enter the timeline Name",
                  errorText: timelineNameError,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent
                        // Red border when error is present
                        ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'TimeLine Description',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timelineDescriptionController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  fillColor: Colors.grey[200],
                  filled: true,
                  hintText: "Enter the timeline Name",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent
                        // Red border when error is present
                        ),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'TimeLine Cover',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: _image == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(SolarIconsBold.addCircle,
                                  color: Colors.purple, size: 70),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: _showUserSearchPopup,
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    //margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(SolarIconsBold.user,
                              color: Colors.white, size: 17),
                          const SizedBox(width: 5),
                          Text(
                            'Add Collaborators',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ],
                      ),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: createTimeLIne,
                child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: colorDark,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    //margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create TimeLine',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ));
  }
}
