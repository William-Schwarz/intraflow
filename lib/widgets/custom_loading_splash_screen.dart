import 'package:flutter/material.dart';

class CustomLoadingSplashscreen extends StatelessWidget {
  const CustomLoadingSplashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 350,
        width: 350,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
