import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class AppTheme {
  // Font family
  static const String fontFamily = 'Satoshi';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  // Text styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    color: TalklinerThemeColors.gray800,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    color: TalklinerThemeColors.gray800,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    color: TalklinerThemeColors.gray800,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: medium,
    color: TalklinerThemeColors.gray800,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: TalklinerThemeColors.gray800,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: TalklinerThemeColors.gray700,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: TalklinerThemeColors.gray600,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    color: Colors.white,
  );

  // Common input decoration properties
  static InputDecorationTheme get _commonInputDecorationTheme =>
      InputDecorationTheme(
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
          color: TalklinerThemeColors.gray500,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: TalklinerThemeColors.primary500,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      );

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: TalklinerThemeColors.primary500,
      primarySwatch: Colors.amber,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: Colors.white,
      dividerTheme: DividerThemeData(
        color: TalklinerThemeColors.gray030,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        displaySmall: headline3,
        headlineMedium: headline4,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: bold,
          color: TalklinerThemeColors.gray800,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        fillColor: TalklinerThemeColors.gray020,
        filled: true,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
          color: TalklinerThemeColors.gray800,
        ),
          enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: TalklinerThemeColors.primary500,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryTextTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: TalklinerThemeColors.gray800,
        filled: true,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
          color: Colors.white,
        ),
        suffixIconColor: TalklinerThemeColors.gray100,
        prefixIconColor: TalklinerThemeColors.gray100,
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
          color: TalklinerThemeColors.gray100,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: TalklinerThemeColors.primary500,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        
      ),
      useMaterial3: true,
      primarySwatch: Colors.amber,
      fontFamily: fontFamily,
      dividerTheme: DividerThemeData(
        color: TalklinerThemeColors.gray700,
        thickness: 1,
      ),
      scaffoldBackgroundColor: TalklinerThemeColors.gray900,
      textTheme: const TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        displaySmall: headline3,
        headlineMedium: headline4,
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: regular,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: regular,
          color: TalklinerThemeColors.gray020,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: regular,
          color: TalklinerThemeColors.gray020,
        ),
        labelLarge: button,
        labelSmall: TextStyle(
          color: TalklinerThemeColors.gray020,
        ),
        labelMedium: TextStyle(
          color: TalklinerThemeColors.gray020,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TalklinerThemeColors.gray900,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: medium,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TalklinerThemeColors.gray900,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        indicatorColor: TalklinerThemeColors.primary500,
      ),
    );
  }
}
