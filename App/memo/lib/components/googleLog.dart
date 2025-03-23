import 'package:flutter/material.dart';
import 'package:memo/services/auth_service.dart'; //aded

class Googlelog extends StatelessWidget {
  final AuthService authService = AuthService(); //added
  /*const*/ Googlelog({super.key});

  void _handleGoogleLogin(BuildContext context) async {
    try {
      await authService.signInWithGoogle();
      Navigator.pushNamed(
          context, '/profile'); // Navigate to profile on success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 236, 236),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google.png',
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Sign in with Google',
            style: const TextStyle(
              color: Color.fromARGB(255, 109, 109, 109),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
