import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blue = Color(0xff1A3A6E);
  static const Color blueLight = Color(0xff163460);
  static const Color bluedDim = Color(0xff0A1628);
  static const Color gold = Color(0xFFC9A84C);

  static const Color navy = Color(0xFF07111F);
  static const Color navyMid = Color.fromARGB(225, 13, 34, 64);
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
    colors: [navyLight, navy],
  );

  static const Color navy900 = Color(0xFF0a0f2e);
  static const Color navy800 = Color(0xFF0D1340);
  static const Color navy700 = Color(0xFF1A2050);
  static const Color navy600 = Color(0xFF2A3270);

  static const Color gold500 = Color(0xFFC9A84C);
  static const Color gold400 = Color(0xFFE8C96A);
  static const Color gold300 = Color(0xFFD4B05A);
  static const Color gold200 = Color(0xFFB8962E);
  static const Color gold100 = Color(0xFFA07830);

  static const Color textLight = Color(0xFFD8CDB0);
  static const Color textHint = Color(0xFF6B5F40);

  static const Color online = Color(0xFF2ECC71);
  static const Color bubbleAiBg = Color(0x14C9A84C); // gold 8% opacity
  static const Color bubbleAiBorder = Color(0x2EC9A84C); // gold 18% opacity
}
