// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stylist_notebook/migration/migration_service.dart';
import 'package:stylist_notebook/screens/ui/main_scaffold.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'screens/appointment.dart';

Future<List<Appointment>> loadAppointments() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/appointments.json');
  if (await file.exists()) {
    final contents = await file.readAsString();
    final List<dynamic> data = jsonDecode(contents);
    return data.map((e) => Appointment.fromJson(e)).toList();
  }
  return [];
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await migrateClientsJson();
  await migrateAppointmentsJson();
  await initializeDateFormatting('ru', null);
  
  final appointments = await loadAppointments(); // <-- добавим эту функцию ниже

  runApp(HairdresserApp(appointments: appointments));
}

class HairdresserApp extends StatefulWidget {
  final List<Appointment> appointments;

  const HairdresserApp({super.key, required this.appointments});

  @override
  State<HairdresserApp> createState() => _HairdresserAppState();
}


final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.pink,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.pinkAccent,
    tertiary: const Color.fromARGB(255, 87, 238, 41),
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
    tertiary: Colors.green,
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
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentTheme,
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
          home: FutureBuilder<List<Appointment>>(
            future: loadAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Ошибка загрузки'));
              } else {
                return MainScaffold(appointments: snapshot.data ?? []);
              }
            },
          ),
        );
      },
    );
  }
}
