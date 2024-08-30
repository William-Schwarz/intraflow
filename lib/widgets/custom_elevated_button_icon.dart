import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomElevatedButtonIcon extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final String label;

  const CustomElevatedButtonIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.tertiaryColor,
      ),
      icon: Icon(
        icon,
        color: CustomColors.secondaryColor,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
