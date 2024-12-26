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
  return Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: logout,
        ),
      ],
    ),
    body: Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 50), // Adds some padding from the top
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 58,
                  child: ClipOval(
                    child: userDetails?['profile_pic'] != null
                        ? Image.network(
                            userDetails?['profile_pic'] as String,
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, size: 58),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.5),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/images/IIT-Campus-Logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      child: const Text(
                        'LEVEL 05',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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


