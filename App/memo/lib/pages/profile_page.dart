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
    backgroundColor: Colors.white, // Set the entire background to white
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        ),
      ],
    ),
    body: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 30,
          left: 97,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Information Card
              Container(
                padding: EdgeInsets.all(12),
                width: 220, // Adjust width for the content
                constraints: BoxConstraints(
                  minHeight: 95, // Minimum height for the container
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    // University Logo
                    CircleAvatar(
                      radius: 20,
                      
                      child: Image.asset(
                        'assets/images/IIT-Campus-Logo.png', 
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 45, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "LEVEL 05",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Profile Picture with Emoji Overlay
              Positioned(
                top: -20,
                left: -40,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 73, // Adjust for the larger profile
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage: AssetImage(''), // Replace with your profile image
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}