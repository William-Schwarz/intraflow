import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'custom_deletion_confirmation_message.dart';

class CustomDeletionSlidable extends StatelessWidget {
  final void Function(BuildContext) onPressed;
  final dynamic child;

  const CustomDeletionSlidable({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDeletionConfirmationMessage(
                    onPressed: () {
                      onPressed(context);
                    },
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(8),
            backgroundColor: CustomColors.tertiaryColor,
            foregroundColor: CustomColors.primaryColor,
            icon: Icons.delete,
            autoClose: true,
          )
        ],
      ),
      child: child,
    );
  }
}
