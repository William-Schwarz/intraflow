import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomElevatedButtonUploadView extends StatelessWidget {
  final String route;
  final String asset;
  final String text;

  const CustomElevatedButtonUploadView({
    super.key,
    required this.route,
    required this.asset,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go(route);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColors.secondaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: ListTile(
          leading: ImageIcon(
            size: 24,
            AssetImage(asset),
            color: Colors.white,
          ),
          title: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
