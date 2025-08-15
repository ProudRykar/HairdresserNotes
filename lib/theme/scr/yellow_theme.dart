// yellow_theme.dart

part of '../theme.dart';

ThemeData createYellowTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.yellow, // базовый цвет для генерации схемы
      brightness: Brightness.light,      
      secondary: AppColors.lightYellow
    ).copyWith(
      primary: AppColors.yellow,
      secondary: AppColors.lightYellow, // ← тут твой secondary
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.yellow,
      titleTextStyle: headlineTextMedium.copyWith(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      contentTextStyle: bodyTextMedium.copyWith(
        color: AppColors.white,
      ),
    ),
    focusColor: AppColors.yellow,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.yellow,
      foregroundColor: AppColors.white,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 2,
    ),
    textTheme: createTextTheme(),
  );
}