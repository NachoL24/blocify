import 'package:flutter/material.dart';

class AppColors {
  static const Color lightSecondaryButton = Color(0xFF333333);
  static const Color lightPermanentWhite = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0C0C0C);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightLightGray = Color(0xFFEBEBEB);
  static const Color lightPrimary = Color(0xFF8A13B2);
  static const Color lightPlaceholder = Color(0xB3212121);
  static const Color lightDrawer = Color(0xFFDEDEDE);
  static const Color lightCard1 = Color(0xFFFFFFFF);
  static const Color lightSecondaryText = Color(0xFF240C3B);

  static const Color darkSecondaryButton = Color(0x808C8C8C);
  static const Color darkPermanentWhite = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0C0C0C);
  static const Color darkLightGray = Color(0xB3323232);
  static const Color darkPrimary = Color(0xFF8A13B2);
  static const Color darkPlaceholder = Color(0xB3FFFFFF);
  static const Color darkDrawer = Color(0x1A8C8C8C);
  static const Color darkCard1 = Color(0x80323232);
  static const Color darkSecondaryText = Color(0xFFAD96C2);

  static Color primary = lightPrimary;
  static Color permanentWhite = lightPermanentWhite;
  static AppColorScheme light = const AppColorScheme(
    secondaryButton: lightSecondaryButton,
    permanentWhite: lightPermanentWhite,
    text: lightText,
    background: lightBackground,
    lightGray: lightLightGray,
    primary: lightPrimary,
    placeholder: lightPlaceholder,
    drawer: lightDrawer,
    card1: lightCard1,
    secondaryText: lightSecondaryText,
  );

  static AppColorScheme dark = const AppColorScheme(
    secondaryButton: darkSecondaryButton,
    permanentWhite: darkPermanentWhite,
    text: darkText,
    background: darkBackground,
    lightGray: darkLightGray,
    primary: darkPrimary,
    placeholder: darkPlaceholder,
    drawer: darkDrawer,
    card1: darkCard1,
    secondaryText: darkSecondaryText,
  );
}

class AppColorScheme {
  const AppColorScheme({
    required this.secondaryButton,
    required this.permanentWhite,
    required this.text,
    required this.background,
    required this.lightGray,
    required this.primary,
    required this.placeholder,
    required this.drawer,
    required this.card1,
    required this.secondaryText,
  });

  final Color secondaryButton;
  final Color permanentWhite;
  final Color text;
  final Color background;
  final Color lightGray;
  final Color primary;
  final Color placeholder;
  final Color drawer;
  final Color card1;
  final Color secondaryText;
}

extension AppColorsExtension on BuildContext {
  AppColorScheme get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }

  Color get primaryColor => AppColors.primary;
  Color get permanentWhite => AppColors.permanentWhite;
}
