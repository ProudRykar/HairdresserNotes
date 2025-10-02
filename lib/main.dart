import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stylist_notebook/migration/migration_service.dart';
import 'package:stylist_notebook/ui/main_scaffold.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'models/appointment.dart';
import 'ui/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:stylist_notebook/screens/load_screen.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await migrateClientsJson();
  await migrateAppointmentsJson();
  await initializeDateFormatting('ru', null);

  runApp(const HairdresserApp());
}

class HairdresserApp extends StatelessWidget {
  const HairdresserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hairdresser Notebook',
            theme: themeProvider.themeData,
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
                  return LoadScreen(); // Показываем заставку
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(child: Text('Ошибка загрузки')),
                  );
                } else {
                  return MainScaffold(appointments: snapshot.data ?? []);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
