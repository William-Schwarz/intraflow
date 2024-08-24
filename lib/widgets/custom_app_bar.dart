import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool leadingVisible;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.leadingVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: leadingVisible ? Colors.white : Colors.black.withOpacity(0.3),
        ),
        onPressed: leadingVisible
            ? () {
                Navigator.pop(context);
              }
            : null,
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              12,
            ),
          ),
          gradient: CustomColors.primaryGradient,
        ),
        child: Center(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
