import 'package:flutter/material.dart';

class AppElevation {
  AppElevation._();

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Vibrant shadows for primary colored elements
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
