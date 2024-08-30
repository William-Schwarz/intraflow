import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String labelText;
  final String hintText;
  final int maxLength;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    this.onChanged,
    required this.labelText,
    required this.hintText,
    required this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        hintText: hintText,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: CustomColors.secondaryColor,
          ),
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      maxLength: maxLength,
    );
  }
}
