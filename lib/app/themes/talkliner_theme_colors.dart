import 'package:flutter/material.dart';

class TalklinerThemeColors {
  // Primary Colors (Orange - Brand, Warning)
  static const Color primary025 = Color(0xFFFCECCD);
  static const Color primary050 = Color(0xFFFBE3B5);
  static const Color primary100 = Color(0xFFF9D083);
  static const Color primary200 = Color(0xFFF6BD51);
  static const Color primary300 = Color(0xFFF5B339);
  static const Color primary400 = Color(0xFFF3AA20);
  static const Color primary500 = Color(0xFFF2A007); // Main
  static const Color primary600 = Color(0xFFDA9006);
  static const Color primary700 = Color(0xFFC28006);
  static const Color primary800 = Color(0xFFA97005);

  // Secondary Colors - Blue (Link)
  static const Color blue025 = Color(0xFFF5F9FF);
  static const Color blue050 = Color(0xFFE6F0FF);
  static const Color blue100 = Color(0xFFB6D5FF);
  static const Color blue200 = Color(0xFF84C2FF);
  static const Color blue300 = Color(0xFF54A3FF);
  static const Color blue400 = Color(0xFF2359FF);
  static const Color blue500 = Color(0xFF0059FF); // Main
  static const Color blue600 = Color(0xFF0055E8);
  static const Color blue700 = Color(0xFF0D3570);
  static const Color blue800 = Color(0xFF00448C);

  // Secondary Colors - Green (Success)
  static const Color green025 = Color(0xFFF1F9F7);
  static const Color green050 = Color(0xFFF5F7F1);
  static const Color green100 = Color(0xFF00DD30);
  static const Color green200 = Color(0xFF45CC8E);
  static const Color green300 = Color(0xFF00CCA0);
  static const Color green400 = Color(0xFF3CC280);
  static const Color green500 = Color(0xFF00B171); // Main
  static const Color green600 = Color(0xFF37A567);
  static const Color green700 = Color(0xFF2F8F50);
  static const Color green800 = Color(0xFF256628);

  // Secondary Colors - Red (Alert, Error)
  static const Color red025 = Color(0xFFFFF5F5);
  static const Color red050 = Color(0xFFFFE6E6);
  static const Color red100 = Color(0xFFFF8787);
  static const Color red200 = Color(0xFFFF9494);
  static const Color red300 = Color(0xFFFF5353);
  static const Color red400 = Color(0xFFFF4545);
  static const Color red500 = Color(0xFFFF0000); // Main
  static const Color red600 = Color(0xFFFF2626);
  static const Color red700 = Color(0xFF6C0700);
  static const Color red800 = Color(0xFF590000);

  // Neutral Colors (Gray)
  static const Color gray0 = Color(0xFFFFFFFF);
  static const Color gray010 = Color(0xFFFBFBFA);
  static const Color gray020 = Color(0xFFF6F6F6);
  static const Color gray030 = Color(0xFFEDEDEE);
  static const Color gray040 = Color(0xFFE1E2E3);
  static const Color gray050 = Color(0xFFC5C7C9);
  static const Color gray060 = Color(0xFFB7B9BB);
  static const Color gray070 = Color(0xFFACAEB1);
  static const Color gray080 = Color(0xFF9EA1A3);
  static const Color gray090 = Color(0xFF909396);
  static const Color gray100 = Color(0xFF828689);
  static const Color gray200 = Color(0xFF74787C);
  static const Color gray300 = Color(0xFF676b6F);
  static const Color gray400 = Color(0xFF5B5F64);
  static const Color gray500 = Color(0xFF4D5257);
  static const Color gray600 = Color(0xFF42474C);
  static const Color gray700 = Color(0xFF31373D);
  static const Color gray800 = Color(0xFF242930);
  static const Color gray900 = Color(0xFF181E25);

  // Getters for main colors
  static Color get primaryMain => primary500;
  static Color get blueMain => blue500;
  static Color get greenMain => green500;
  static Color get redMain => red500;

  // Functional color getters
  static Color get warning => primary500;
  static Color get link => blue500;
  static Color get success => green500;
  static Color get error => red500;
  static Color get alert => red500;

  // Background colors
  static Color get background => gray010;
  static Color get surfaceBackground => gray020;
}