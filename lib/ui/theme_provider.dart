import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylist_notebook/theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = createBlueTheme();
  String _themeName = 'light';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;
  String get themeName => _themeName;

  void setTheme(String themeName) async {
    _themeName = themeName;

    ThemeData baseTheme;
    switch (themeName) {
      case 'light':
        baseTheme = createLightTheme();
        break;
      case 'dark':
        baseTheme = createDarkTheme();
        break;
      case 'yellow':
        baseTheme = createYellowTheme();
        break;
      case 'purple':
        baseTheme = createPurpleTheme();
        break;
      case 'blue':
        baseTheme = createBlueTheme();
        break;
      case 'green':
        baseTheme = createGreenTheme();
        break;
      case 'red':
        baseTheme = createRedTheme();
        break;
      case 'dark_blue':
        baseTheme = createDarkBlueTheme();
        break;
      case 'light_blue':
        baseTheme = createLightBlueTheme();
        break;
      case 'normal_blue':
        baseTheme = createNormalBlueTheme();
        break;
      default:
        baseTheme = createLightTheme();
    }

    _themeData = baseTheme.copyWith(
      scaffoldBackgroundColor: themeName == 'black' ? AppColors.lightDark : AppColors.white,
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: themeName == 'black' ? AppColors.lightDark : AppColors.white,
      ),
    );


    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'light';
    setTheme(savedTheme);
  }
}