import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stylist_notebook/migration/migration_service.dart';
import 'package:stylist_notebook/screens/first_launch_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'models/appointment.dart';
import 'ui/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:stylist_notebook/screens/load_screen.dart';

Future<List<Appointment>> loadAppointments() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/appointments.json');
    debugPrint('Looking for file: ${file.path}');
    
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> data = jsonDecode(contents);
      return data.map((e) => Appointment.fromJson(e)).toList();
    } else {
      debugPrint('File not found. Creating a new one.');
      await file.writeAsString('[]');
      return [];
    }
  } catch (e, st) {
    debugPrint('Error while loading appointments: $e\n$st');
    return [];
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await migrateClientsJson();
  await migrateAppointmentsJson();
  await initializeDateFormatting('ru', null);

  runApp(const HairdresserApp());
}

class HairdresserApp extends StatefulWidget {
  const HairdresserApp({super.key});

  @override
  State<HairdresserApp> createState() => _HairdresserAppState();
}

class _HairdresserAppState extends State<HairdresserApp> {
  late final Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointmentsWithDelay();
  }

  Future<List<Appointment>> _loadAppointmentsWithDelay() async {
    final appointmentsFuture = loadAppointments();
    final delayFuture = Future.delayed(const Duration(seconds: 2));
    final results = await Future.wait([appointmentsFuture, delayFuture]);
    return results[0] as List<Appointment>;
  }

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
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                debugPrint('Builder: ${snapshot.connectionState}, error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadScreen();
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(child: Text('Ошибка загрузки')),
                  );
                } else {
                  return FirstLaunchScreen(appointments: snapshot.data ?? []);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
