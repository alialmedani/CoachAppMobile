import 'package:flutter/material.dart';
 import 'app_font_weight.dart';
import 'font_size.dart';

class AppTextStyle {
  static TextStyle getTextStyle(
    double fontSize,
    double height,
    Color color,
    FontWeight fontWeight,
    String? fontFamily, {
    TextDecoration? textDecoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontSize: fontSize,
      height: height,
      color: color,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      decoration: textDecoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle getRegularStyle({
    double fontSize = AppFontSize.size_12,
    FontWeight? fontWeight,
    required Color color,
    double? height,
    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return getTextStyle(
      fontSize,
      height ?? 0,
      color,
      fontWeight ?? AppFontWeight.regular,
      fontFamily ?? "Cairo",
      textDecoration: textDecoration,
    );
  }

  static TextStyle getMediumStyle({
    double fontSize = AppFontSize.size_12,
    required Color color,
    double? height,
    FontWeight? fontWeight,
    String? fontFamily,
  }) {
    return getTextStyle(
      fontSize,
      height ?? 0,
      color,
      fontWeight ?? AppFontWeight.medium,
      "Cairo",
    );
  }

  static TextStyle getLightStyle({
    double fontSize = AppFontSize.size_12,
    required Color color,
    double? height,
    FontWeight? fontWeight,
    String? fontFamily,
  }) {
    return getTextStyle(
      fontSize,
      height ?? 0,
      color,
      fontWeight ?? AppFontWeight.light,
      "Cairo",
    );
  }

  static TextStyle getBoldStyle({
    double fontSize = AppFontSize.size_12,
    required Color color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? height,

    TextDecoration? textDecoration,
  }) {
    return getTextStyle(
      fontSize,
      height ?? 0,
      color,
      fontWeight ?? AppFontWeight.bold,
      "Cairo",
      textDecoration: textDecoration,
    );
  }

  static TextStyle getSemiBoldStyle({
    double fontSize = AppFontSize.size_12,
    required Color color,
    FontWeight? fontWeight,
    double? height,

    String? fontFamily,
    TextDecoration? textDecoration,
  }) {
    return getTextStyle(
      fontSize,
      height ?? 0,
      color,
      fontWeight ?? AppFontWeight.semiBold,
      "Cairo",
      textDecoration: textDecoration,
    );
  }

  static const normalWhite_12 = TextStyle(
    fontSize: AppFontSize.size_12,
    color: Colors.white,
    fontWeight: FontWeight.normal,
    fontFamily: 'Cairo',
  );

  TextStyle h1Style = const TextStyle(
    fontSize: 60,
    color: Colors.black,
    fontFamily: 'Barlow',
    height: 1.4,
    fontWeight: FontWeight.w900,
  );

  TextStyle h2Style = const TextStyle(
    fontSize: 30,
    color: Colors.black,
    fontFamily: 'Barlow',
    fontWeight: FontWeight.bold,
  );

  TextStyle h3Style = const TextStyle(
    fontSize: 26,
    color: Colors.black,
    fontFamily: 'Barlow',
    fontWeight: FontWeight.w500,
  );

  TextStyle h4Style = const TextStyle(
    fontFamily: 'Barlow',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  TextStyle h5Style = const TextStyle(
    fontFamily: 'Barlow',
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  TextStyle h6Style = const TextStyle(
    fontFamily: 'Barlow',
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );

  TextStyle bodyStyle1 = const TextStyle(
    fontFamily: 'Barlow',
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle bodyStyle2 = const TextStyle(
    fontFamily: 'Barlow',
    fontSize: 16,
    color: Colors.grey,
  );

  static const textFieldStyle = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
  );
}
