import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blue = Color(0xff1A3A6E);
  static const Color blueLight = Color(0xff163460);
  static const Color bluedDim = Color(0xff0A1628);
  static const Color gold = Color(0xFFC9A84C);

  static const Color navy = Color(0xFF07111F);
  static const Color navyMid = Color(0xFF0d2240);
  static const Color navyLight = Color(0xFF1b4a89);
  static const Color navyCard = Color(0xFF102035);
  static const Color navyInput = Color(0xFF091728);
  static const Color navyBorder = Color(0x33C9A84C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color textSub = Color(0xFF8BA3BF);
  static const Color textMuted = Color(0xFF4A647E);
  static const Color backGround = Color(0xfffaf7f2);

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blueLight, Color.fromARGB(255, 19, 43, 80)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    colors: [navyLight, navyMid, navy],
  );
}
