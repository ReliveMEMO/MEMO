import 'package:flutter/material.dart';

class Authbutton extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;

  const Authbutton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7f31c6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
