import 'package:flutter/material.dart';

class AppFonts {
  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'Montserrat',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }

  static TextStyle jetBrainsMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
    );
  }
}