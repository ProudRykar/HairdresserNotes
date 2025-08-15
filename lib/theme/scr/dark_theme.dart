// dark_theme.dart
part of '../theme.dart';

ThemeData createDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.black, // базовый цвет для генерации схемы
      brightness: Brightness.light,
      secondary: AppColors.lightGrey
    ).copyWith(
      primary: AppColors.black,
      secondary: AppColors.lightGrey, // ← тут твой secondary
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.black,
      titleTextStyle: headlineTextMedium.copyWith(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      contentTextStyle: headlineTextMedium.copyWith(
        color: AppColors.white,
      ),
    ),
    focusColor: Colors.blue,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
  );
}