part of '../theme.dart';

ThemeData createDarkBlueTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkBlue, // базовый цвет для генерации схемы
      brightness: Brightness.light,
      secondary: AppColors.lightBlue
    ).copyWith(
      primary: AppColors.darkBlue,
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
    focusColor: AppColors.darkBlue,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBlue,
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
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        textStyle: bodyTextMedium,
      ),
    ),
  );
}
