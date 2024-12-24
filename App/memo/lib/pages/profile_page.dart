import 'package:flutter/material.dart';
import 'package:memo/components/bottom_nav.dart';
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
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
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
              Text(
                'Welcome $userLoggedIn',
                style: const TextStyle(fontSize: 24, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ]),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
