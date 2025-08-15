part of '../theme.dart';

ThemeData createRedTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red, // базовый цвет для генерации схемы
      brightness: Brightness.light,
      secondary: AppColors.lightRed
    ).copyWith(
      primary: AppColors.red,
      secondary: AppColors.lightRed, // ← тут твой secondary
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      titleTextStyle: headlineTextMedium.copyWith(
        color: AppColors.black,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      contentTextStyle: bodyTextMedium.copyWith(
        color: AppColors.black,
      ),
    ),
    focusColor: AppColors.red,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.red,
      foregroundColor: AppColors.white,
    ),
    textTheme: createTextTheme().copyWith(
      titleMedium: bodyTextMedium.copyWith(
        color: AppColors.black,
      ),
      bodyMedium: bodyTextMedium.copyWith(
        color: AppColors.black,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.white,
        textStyle: bodyTextMedium,
      ),
    ),
  );
}