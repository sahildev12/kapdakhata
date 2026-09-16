import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primaryPurple = Color(0xFF7132F5);
  static const darkPurple = Color(0xFF5741D8);
  static const deepPurple = Color(0xFF5B1ECF);
  static const purpleSubtle = Color(0x29855BFB);

  static const primaryText = Color(0xFF101114);
  static const neutralText = Color(0xFF686B82);
  static const mutedText = Color(0xFF9497A9);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFDEDEE5);

  static const positiveGreen = Color(0xFF149E61);
  static const darkGreen = Color(0xFF026B3F);
  static const greenSubtle = Color(0x29149E61);
  static const graySubtle = Color(0x149497A9);

  static const negativeRed = Color(0xFFE53935);
  static const redSubtle = Color(0x1AE53935);
  static const orangeAccent = Color(0xFFE67E22);
  static const orangeSubtle = Color(0x1AE67E22);
  static const pinkAccent = Color(0xFFE84393);
  static const pinkSubtle = Color(0x1AE84393);
  static const blueAccent = Color(0xFF3B82F6);
  static const blueSubtle = Color(0x1A3B82F6);
  static const lavenderSubtle = Color(0x1A7132F5);

  static const cardShadow = BoxShadow(
    color: Color(0x08000000),
    blurRadius: 24,
    offset: Offset(0, 4),
  );
}
