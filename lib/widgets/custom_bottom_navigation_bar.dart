import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final List<Map<String, dynamic>> bottomNavItems;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
    required this.bottomNavItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        gradient: CustomColors.primaryGradient,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        elevation: 0,
        items: bottomNavItems.map((item) {
          return showBottomNavigationBarItem(
            item['asset'],
            item['label'],
          );
        }).toList(),
      ),
    );
  }

  BottomNavigationBarItem showBottomNavigationBarItem(
    String asset,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage(asset),
      ),
      label: label,
    );
  }
}
