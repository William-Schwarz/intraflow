import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomErrorMessaging extends StatelessWidget {
  final String message;

  const CustomErrorMessaging({
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
          'assets/images/svgs/cancel_485156.svg',
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
            'OK',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomErrorMessaging(message: message);
      },
    );
  }
}
