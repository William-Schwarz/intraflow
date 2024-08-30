import 'package:flutter/material.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';

class CustomDeletionConfirmationMessage extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomDeletionConfirmationMessage({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
            size: 50,
          ),
          SizedBox(width: 16.0),
          Text('Exlcusão!'),
        ],
      ),
      content: const Text(
        'Deseja realmente excluir?',
        style: TextStyle(fontSize: 16),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () {
            onPressed();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).clearSnackBars();
            CustomSnackBar.showDefault(
                context, 'Exclusão concluída com sucesso!');
          },
          child: const Text(
            'Confimar',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  static void showDeleteConfirmationDialog(
    BuildContext context,
    VoidCallback onPressed,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDeletionConfirmationMessage(
          onPressed: onPressed,
        );
      },
    );
  }
}
