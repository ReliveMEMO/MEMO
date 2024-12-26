import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  PostgrestMap? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void logout() async {
    await authService.signOut();
    Navigator.pushNamed(context, '/login');
  }

  void getUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('User_Info')
        .select()
        .eq('id', authService.getCurrentUserID()!)
        .maybeSingle();
    setState(() {
      userDetails = response;
    });

    print(response);
    setState(() {
      isLoading = false;
    });
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
    body: Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 50), // Adds some padding from the top
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 68), // Padding from the left
                CircleAvatar(
                  radius: 58,
                  child: ClipOval(
                    child: userDetails?['profile_pic'] != null
                        ? Image.network(
                            userDetails?['profile_pic'] as String,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(width: 20), 
                Container(
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5), 
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), 
                    child: Image.asset(
                      "assets/images/IIT-Campus-Logo.png", 
                      width: 50, 
                      height: 50, 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    ),
  );
}
}