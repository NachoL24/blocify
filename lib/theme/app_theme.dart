import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondaryButton,
        surface: AppColors.lightCard1,
        background: AppColors.lightBackground,
        onPrimary: AppColors.lightPermanentWhite,
        onSecondary: AppColors.lightPermanentWhite,
        onSurface: AppColors.lightText,
        onBackground: AppColors.lightText,
        outline: AppColors.lightLightGray,
      ),
      
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.lightCard1,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightPermanentWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightSecondaryButton,
          side: BorderSide(color: AppColors.lightSecondaryButton),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightLightGray,
        hintStyle: TextStyle(color: AppColors.lightPlaceholder),
        labelStyle: TextStyle(color: AppColors.lightSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
      ),
      
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.lightDrawer,
      ),
      
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        bodySmall: TextStyle(color: AppColors.lightSecondaryText),
        labelLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500),
      ),
      
      fontFamily: 'Roboto',
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondaryButton,
        surface: AppColors.darkCard1,
        background: AppColors.darkBackground,
        onPrimary: AppColors.darkPermanentWhite,
        onSecondary: AppColors.darkPermanentWhite,
        onSurface: AppColors.darkText,
        onBackground: AppColors.darkText,
        outline: AppColors.darkLightGray,
      ),
      
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.darkCard1,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkPermanentWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkSecondaryButton,
          side: BorderSide(color: AppColors.darkSecondaryButton),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkLightGray,
        hintStyle: TextStyle(color: AppColors.darkPlaceholder),
        labelStyle: TextStyle(color: AppColors.darkSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
      ),
      
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.darkDrawer,
      ),
      
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        bodySmall: TextStyle(color: AppColors.darkSecondaryText),
        labelLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w500),
      ),
      
      fontFamily: 'Roboto',
    );
  }
}
