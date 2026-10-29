import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.mandyRed,
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    subThemesData: const FlexSubThemesData(
      alignedDropdown: true,
    ),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.mandyRed,
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    subThemesData: const FlexSubThemesData(
      alignedDropdown: true,
    ),
  );
}