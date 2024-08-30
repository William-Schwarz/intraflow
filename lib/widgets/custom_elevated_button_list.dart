import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomElevatedButtonList extends StatelessWidget {
  final Key buttonkey;
  final Future<void> Function() onPressed;
  final bool listIsOpen;
  final String text;

  const CustomElevatedButtonList({
    super.key,
    required this.buttonkey,
    required this.onPressed,
    required this.listIsOpen,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: buttonkey,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: CustomColors.secondaryColor,
          padding: const EdgeInsets.all(
            25.0,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          listIsOpen ? 'Fechar Lista' : text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
