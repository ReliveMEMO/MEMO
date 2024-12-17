import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:memo/components/dropDown.dart'; 

void profilePage() {
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  String? selectedProgram; 

  void logout() async {
    await authService.signOut();
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn = authService.getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome $userLoggedIn',
              style: const TextStyle(fontSize: 24, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20), 
            DropdownComponent(
              hintText: ' Programme',
              items: ['Software Engineering', 'Computer Science', 'AI and Data Science', 'Business Information Systems'], // Dropdown options
              onChanged: (value) {
                setState(() {
                  selectedProgram = value; 
                });
              },
              selectedValue: selectedProgram, 
            ),
          ],
        ),
      ),
    );
  }
}   


