import 'package:flutter/material.dart';


class AppTextStyle {
  static TextStyle h6 = new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0, letterSpacing: 0.25, color: CompanyColors.blue);
  static TextStyle h5HighEmp = new TextStyle(fontWeight: FontWeight.w400, fontSize: 24.0, letterSpacing: 0.0, color: Colors.grey[900]);
  static TextStyle h6HighEmp = new TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0, letterSpacing: 0.0, color: Colors.grey[900]);

  static TextStyle ovlnMedEmp = new TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, letterSpacing: 2.0, color: Colors.grey[700]);
  static TextStyle ovlnHighEmp = new TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, letterSpacing: 2.0, color: Colors.grey[900]);

  static TextStyle ovlnAccCol = new TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, letterSpacing: 2.0, color: CompanyColors.yellow);
  static TextStyle subMedEmp = new TextStyle(fontWeight:  FontWeight.w400, fontSize: 16.0, letterSpacing: 0.15, color: Colors.grey[600]);
  static TextStyle subPrimary = new TextStyle(fontWeight:  FontWeight.w400, fontSize: 16.0, letterSpacing: 0.15, color: CompanyColors.blue);
  static TextStyle body2MedEmp = new TextStyle(fontWeight:  FontWeight.w400, fontSize: 14.0, letterSpacing: 0.5, color: Colors.grey[500], height: 1.2);
  static TextStyle body2HighEmp = new TextStyle(fontWeight:  FontWeight.w400, fontSize: 14.0, letterSpacing: 0.5, color: Colors.grey[900], height: 1.2);

  static TextStyle bodyMedEmp = new TextStyle(fontWeight:  FontWeight.w400, fontSize: 16.0, letterSpacing: 0.5, color: Colors.grey[500], height: 1.2);
}

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class

  static const _bluePrimaryValue = 0xFF003e7e;
  static const _yellowPrimaryValue = 0xFFffc423;

  static const MaterialColor blue = const MaterialColor(
    _bluePrimaryValue,
    const <int, Color>{
      50:  const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(_bluePrimaryValue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  static const MaterialColor yellow = const MaterialColor(
    _yellowPrimaryValue,
    const <int, Color>{
      50:  const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(_yellowPrimaryValue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );
}