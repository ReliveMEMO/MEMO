import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarUpload extends StatefulWidget {
  const AvatarUpload({super.key});

  @override
  State<AvatarUpload> createState() => _AvatarUploadState();
}

class _AvatarUploadState extends State<AvatarUpload> {
  File? _imageFile;

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future uploadImage() async {
    if (_imageFile == null) {
      return;
    }

    final FileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$FileName';

    await Supabase.instance.client.storage
        .from('profile-pictures')
        .upload(path, _imageFile!)
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Image uploaded successfully")),
            ));
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
                  width: 200,
                  height: 200,
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
          ElevatedButton(
              onPressed: uploadImage, child: const Text("Upload Image")),
        ],
      ),
    );
  }
}
