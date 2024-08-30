import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomWarningMessaging extends StatelessWidget {
  final String message;

  const CustomWarningMessaging({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        height: 200,
        width: 200,
        child: SvgPicture.asset(
          'assets/images/svgs/notify_485156.svg',
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Ok',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  static void showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomWarningMessaging(message: message);
      },
    );
  }
}
