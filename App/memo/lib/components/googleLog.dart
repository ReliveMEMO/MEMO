import 'package:flutter/material.dart';

class Googlelog extends StatelessWidget {
  const Googlelog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
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
      ),
    );
  }
}
