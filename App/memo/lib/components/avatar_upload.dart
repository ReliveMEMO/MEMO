import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarUpload extends StatefulWidget {
  final Function(File?) onImageSelected;

  const AvatarUpload({super.key, required this.onImageSelected});

  @override
  State<AvatarUpload> createState() => _AvatarUploadState();
}

class _AvatarUploadState extends State<AvatarUpload> {
  File? _imageFile;

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image size must be less than 10MB")),
        );
        return;
      }
      setState(() {
        _imageFile = File(image.path);
      });

      // Pass the selected image back to the parent widget
      widget.onImageSelected(_imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Image.asset("assets/images/user.png",
                          fit: BoxFit.cover),
                ),
              ),
              Positioned(
                bottom: -20,
                child: FloatingActionButton(
                    onPressed: pickImage,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                    child: const Icon(Icons.add)),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
