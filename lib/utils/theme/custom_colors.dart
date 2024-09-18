import 'package:flutter/material.dart';

class CustomColors {
  static const Color primaryColor = Color.fromRGBO(255, 94, 77, 1.0);
  static const Color secondaryColor = Color.fromRGBO(96, 119, 131, 1);
  static const Color tertiaryColor = Color.fromRGBO(182, 201, 218, 1.0);
  static Color boxShadowColor = const Color.fromRGBO(182, 201, 218, 1.0).withOpacity(0.5);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(255, 64, 129, 1.0),
      Color.fromRGBO(255, 94, 77, 1.0),
      Color.fromRGBO(41, 182, 246, 1.0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}
