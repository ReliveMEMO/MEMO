import 'package:flutter/material.dart';

class DropdownComponent extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  final Color backgroundColor = const Color(0xFFF8F0FF);
  final Color textColor = const Color(0xFF7f31c6);
  final String? errorText;
  final VoidCallback? clearErrorText;

  const DropdownComponent({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.errorText,
    this.clearErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.transparent,
              ),
              // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                onChanged: (value) {
                  onChanged(value);
                  if (value != null &&
                      value.isNotEmpty &&
                      clearErrorText != null) {
                    clearErrorText!();
                  }
                },
                hint: Text(
                  hintText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF7F31C6), // Icon color
                ),
                isExpanded: true,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                dropdownColor: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                elevation: 1, // Reduced shadow opacity
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
