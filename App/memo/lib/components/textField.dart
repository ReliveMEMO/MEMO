import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final controller;
  final Color colorLight = const Color.fromARGB(255, 245, 234, 255);
  final Color colorDark = const Color(0xFF7f31c6);

  const TextFieldComponent({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorDark,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          fillColor: colorLight,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorDark),
          ),
        ),
      ),
    );
  }
}
