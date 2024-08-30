import 'package:flutter/material.dart';
import 'package:intraflow/widgets/custom_image_thumb_list.dart';

class CustomListTile extends StatelessWidget {
  final String thumbURL;
  final String title;
  final String trailingText;

  const CustomListTile({
    Key? key,
    required this.thumbURL,
    required this.title,
    required this.trailingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: CustomImageThumbList(
          thumbURL: thumbURL,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      trailing: Text(
        trailingText,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
