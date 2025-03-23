import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:memo/components/timeLine_search.dart';
import 'package:image/image.dart' as img;
import 'package:memo/components/user_search.dart';
import 'package:memo/pages/my_page.dart';
import 'package:memo/pages/timeLine_page.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewMemo extends StatefulWidget {
  @override
  _NewMemoState createState() => _NewMemoState();
}

class _NewMemoState extends State<NewMemo> {
  final authService = AuthService();
  File? _selectedImage;
  final _captionController = TextEditingController();
  final _headingController = TextEditingController();
  final _noteController = TextEditingController(); // For Note section
  final FocusNode _milestoneFocusNode = FocusNode();
  final TextEditingController _milestoneTextController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String selectedTab = "Post";
  DateTime? selectedDate = DateTime.now();
  Map<String, dynamic>? timelineId;
  String timeLineName = "Timeline Name";
  List<String> collaborators = [];
  File? _image;
  String? imageUrl;

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
            img.copyResize(croppedImage, width: 500, height: 500);
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
      imageUrl =
          'https://qbqwbeppyliavvfzryze.supabase.co/storage/v1/object/public/timeline_covers/uploads/Timeline%20Cover.png';
      return;
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    await Supabase.instance.client.storage
        .from('memos')
        .upload(path, _selectedImage!);

    final url =
        await Supabase.instance.client.storage.from('memos').getPublicUrl(path);

    imageUrl = url;
  }

  Future<void> postMemo() async {
    try {
      await uploadImage();

      final userId = authService.getCurrentUserID();

      final response =
          await Supabase.instance.client.from('Post_Table').insert({
        'heading': _headingController.text,
        'caption': _captionController.text,
        'image_url': imageUrl,
        'owner_id': userId,
        'timeline_id': timelineId!['id'],
        'tags': collaborators,
        'date': selectedDate?.toUtc().toIso8601String(),
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => myPage(
                    index: 0,
                  )));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void showTimeLinePopUp() {
    showDialog(
        context: context,
        builder: (context) {
          return TimelineSearch(timeLineSelected: (timeLineSelected) {
            setState(() {
              timelineId = timeLineSelected;
              timeLineName = timeLineSelected!['timeline_name'];
            });
            print(timelineId);
          });
        });
  }

  void showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Error"),
          content: Text("Please select a timeline."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showUserSearchPopup() {
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "New MEMO",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                child: ElevatedButton(
                  onPressed: timeLineName == "Timeline Name"
                      ? showError
                      : () {
                          postMemo();
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7D17BA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      elevation: 0 // Reduced vertical padding
                      ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Name and Post/Note/Milestone on Same Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150, // Set the fixed width here
                    child: ElevatedButton(
                      onPressed: showTimeLinePopUp,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEADCF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          elevation: 0),
                      child: Text(
                        timeLineName,
                        style: TextStyle(
                          color: Color(0xFF7D17BA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = "Post";
                            });
                          },
                          child: Text(
                            "Post",
                            style: TextStyle(
                              color: selectedTab == "Post"
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = "Note";
                            });
                          },
                          child: Text(
                            "Note",
                            style: TextStyle(
                              color: selectedTab == "Note"
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = "Milestone";
                            });
                          },
                          child: Text(
                            "Milestone",
                            style: TextStyle(
                              color: selectedTab == "Milestone"
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Post Section
              if (selectedTab == "Post") ...[
                Text(
                  "Heading",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _headingController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "New Memo",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 350,
                                ),
                              )
                            : SizedBox.shrink(),
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 128, 44, 219),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Caption",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: "Enter Caption...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 60,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showUserSearchPopup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Tag Friends",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context); // Open date picker
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" // Display formatted date
                            : "Date", // Default text
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Action for location
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Location",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],

              // Note Section
              if (selectedTab == "Note") ...[
                Text(
                  "Heading",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _headingController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "New Memo 12.11.2024",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Note",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: "Write your note here...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action for tagging friends
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Tag Friends",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context); // Open date picker
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" // Display formatted date
                            : "Date", // Default text
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],

              // Milestone Section
              if (selectedTab == "Milestone") ...[
                Text(
                  "Heading",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _headingController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "New Memo 12.11.2024",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Emoji",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // TextField for emoji input
                    TextField(
                        focusNode: _milestoneFocusNode,
                        controller: _milestoneTextController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical
                            .center, // Center the cursor vertically
                        style: TextStyle(fontSize: 60), // Large text for emoji
                        onChanged: (value) {
                          setState(
                              () {}); // Update the UI dynamically when emoji is entered
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 20,
                          ),
                        )),
                    // Plus icon overlay (conditionally hidden)
                    if (_milestoneTextController.text.isEmpty &&
                        !_milestoneFocusNode.hasFocus)
                      GestureDetector(
                        onTap: () {
                          // Show keyboard when plus icon is clicked
                          FocusScope.of(context)
                              .requestFocus(_milestoneFocusNode);
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Color(0xFF7D17BA), // Purple background
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add, // Plus icon
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Caption",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: "Enter Caption...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 60,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: showUserSearchPopup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Tag Friends",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context); // Open date picker
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" // Display formatted date
                            : "Date", // Default text
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Action for location
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Location",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
