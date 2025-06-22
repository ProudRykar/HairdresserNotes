// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_screen.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  runApp(const HairdresserApp());
}

class HairdresserApp extends StatefulWidget {
  const HairdresserApp({super.key});

  @override
  State<HairdresserApp> createState() => _HairdresserAppState();
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.pink,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.pinkAccent,
    tertiary: const Color.fromARGB(255, 87, 238, 41), // 💚 зелёный для суммы в тёмной теме
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 255, 192, 203),
    foregroundColor: Colors.black,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 44, 44, 44),
  colorScheme: const ColorScheme.dark(
    secondary: Colors.tealAccent,
    tertiary: Colors.green, // 💚 зелёный для суммы в светлой теме
  ),
  primaryColor: Colors.tealAccent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 44, 44, 44),
    foregroundColor: Colors.white,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color.fromARGB(255, 44, 44, 44),
  ),
  iconTheme: const IconThemeData(color: Colors.tealAccent),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);


class _HairdresserAppState extends State<HairdresserApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hairdresser Notebook',
          theme: lightTheme,      // 💡 светлая тема
          darkTheme: darkTheme,   // 🌑 тёмная тема
          themeMode: currentTheme, // 👈 переключение темы
          locale: const Locale('ru', 'RU'),
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}
