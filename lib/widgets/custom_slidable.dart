import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomSlidable extends StatelessWidget {
  final bool enable;
  final void Function(BuildContext) onPressed;
  final IconData icon;
  final String label;
  final dynamic child;

  const CustomSlidable({
    super.key,
    required this.enable,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: enable,
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: onPressed,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: CustomColors.tertiaryColor,
            foregroundColor: Colors.black,
            icon: icon,
            label: label,
          ),
        ],
      ),
      child: child,
    );
  }
}
