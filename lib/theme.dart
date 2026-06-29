import 'package:flutter/material.dart';

const hpBackground = Color(0xFFF4F7FF);
const hpPanel = Color(0xFFFFFFFF);
const hpCard = Color(0xFFEAF1FF);
const hpTeal = Color(0xFF062B86);
const hpOrange = Color(0xFF1E5BCE);
const hpText = Color(0xFF071B3A);
const hpMuted = Color(0xFF52647F);
const hpSubtle = Color(0xFF8FA0BA);
const hpInk = Color(0xFFFFFFFF);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: hpBackground,
    colorScheme: const ColorScheme.light(
      primary: hpTeal,
      secondary: hpOrange,
      surface: hpPanel,
      onPrimary: hpInk,
      onSecondary: hpInk,
      onSurface: hpText,
    ),
    cardTheme: CardThemeData(
      color: hpPanel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: hpTeal,
        foregroundColor: hpInk,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: hpText),
      bodySmall: TextStyle(color: hpMuted),
    ),
  );
}
