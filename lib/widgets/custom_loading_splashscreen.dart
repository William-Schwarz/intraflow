import 'package:flutter/material.dart';

class CustomLoadingSplashscreen extends StatelessWidget {
  const CustomLoadingSplashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 300,
        width: 300,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
