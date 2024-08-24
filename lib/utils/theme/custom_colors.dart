import 'package:flutter/material.dart';

class CustomColors {
  //static const Color primaryColor = Color.fromARGB(255, 156, 16, 6);
  static const Color primaryColor = Color.fromRGBO(156, 16, 6, 1.0);
  static const Color secondaryColor = Color.fromRGBO(72, 81, 86, 1.0);
  static const Color tertiaryColor = Color.fromRGBO(182, 201, 218, 1.0);
  static Color boxShadowColor =
      const Color.fromRGBO(182, 201, 218, 1.0).withOpacity(0.5);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(235, 63, 93, 1.0),
      Color.fromRGBO(239, 116, 56, 1.0),
      Color.fromRGBO(233, 40, 110, 1.0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}
