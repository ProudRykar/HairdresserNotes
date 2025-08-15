part of '../theme.dart';

const headlineTextMedium = TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
const bodyTextMedium = TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

abstract class AppColors {
  static const white = Colors.white;
  static const black = Colors.black;
  static const blue = Colors.blue;
  static const lightBlue = Color.fromARGB(255, 122, 195, 255);
  static const lightLightBlue = Color(0xFF73B7FF);
  static const normalBlue = Color(0xFF127DED);
  static const darkBlue = Color.fromARGB(255, 8, 74, 187);
  static const yellow = Color.fromARGB(255, 252, 164, 1);
  static const lightYellow = Color.fromARGB(255, 255, 203, 90);
  static const lightPurple = Color.fromARGB(255, 231, 164, 243);
  static const purpleAccent = Colors.purpleAccent;
  static const green = Colors.green;
  static const lightGreen = Color.fromARGB(255, 144, 238, 144);
  static const red = Color.fromARGB(255, 202, 49, 49);
  static const lightRed = Color.fromARGB(255, 255, 102, 102);

  static const error = Colors.red;
  static const darkerRed = Color(0xFFCB5A5E);

  static const grey = Colors.grey;
  static const darkerGrey = Color(0xFF6C6C6C);
  static const darkestGrey = Color(0xFF626262);
  static const lighterGrey = Color(0xFF959595);
  static const lightGrey = Color(0xFF5d5d5d);

  static const lighterDark = Color(0xFF272727);
  static const lightDark = Color(0xFF1b1b1b);
}