import 'package:flutter/material.dart';
import 'package:memo/pages/create_profile.dart';
import 'package:memo/pages/login_page.dart';
import 'package:memo/pages/profile_page.dart';
import 'package:memo/pages/signup_page.dart';
import 'package:memo/pages/verify_email_page.dart';
import 'package:memo/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFicXdiZXBweWxpYXZ2ZnpyeXplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1ODU5NTcsImV4cCI6MjA0OTE2MTk1N30.dKEe4wJ7lJq87GKHzgIR-U-jUYpV3pZWgXQuMpeU9DU",
    url: "https://qbqwbeppyliavvfzryze.supabase.co",
  );

  runApp(const MyApp());
}

//final Supabase = Supabase.instance.clinet; //supabase

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const authGate(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/profile': (context) => ProfilePage(),
        '/create-profile': (context) => CreateProfile(),
        '/verify-acc': (context) => VerifyEmailPage(),
        //Testing the CI pipeline xoxo
      },
    );
  }
}
