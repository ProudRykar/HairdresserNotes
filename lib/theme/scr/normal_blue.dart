part of '../theme.dart';

ThemeData createNormalBlueTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.normalBlue, // базовый цвет для генерации схемы
      brightness: Brightness.light,
      secondary: AppColors.lightBlue
    ).copyWith(
      primary: AppColors.normalBlue,
      secondary: AppColors.lightBlue, // ← тут твой secondary
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
    focusColor: AppColors.lightLightBlue,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.normalBlue,
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
        backgroundColor: AppColors.normalBlue,
        foregroundColor: AppColors.white,
        textStyle: bodyTextMedium,
      ),
    ),
  );
}