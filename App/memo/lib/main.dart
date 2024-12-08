import 'package:flutter/material.dart';
import 'package:memo/pages/login_page.dart';
import 'package:memo/pages/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
