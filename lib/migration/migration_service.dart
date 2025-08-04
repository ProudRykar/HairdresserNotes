import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> migrateClientsJson() async {
  final prefs = await SharedPreferences.getInstance();
  final isMigrated = prefs.getBool('clientsMigrated') ?? false;
  if (isMigrated) return;

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/clients.json');

  if (await file.exists()) {
    final jsonString = await file.readAsString();
    final List<dynamic> clients = jsonDecode(jsonString);

    final migratedClients = clients.map((client) {
      return {
        'name': client['name'],
        'phone': client['phone'],
        'telegram_id': '',
      };
    }).toList();

    await file.writeAsString(jsonEncode(migratedClients));
  }

  await prefs.setBool('clientsMigrated', true);
}

Future<void> migrateAppointmentsJson() async {
  final prefs = await SharedPreferences.getInstance();
  final isMigrated = prefs.getBool('appointmentsMigrated') ?? false;
  if (isMigrated) return;

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/appointments.json');

  if (await file.exists()) {
    final jsonString = await file.readAsString();
    final List<dynamic> appointments = jsonDecode(jsonString);

    final migratedAppointments = appointments.map((appointment) {
      return {
        'name': appointment['name'],
        'service': appointment['service'],
        'dateTime': appointment['dateTime'],
        'earnings': appointment['earnings'],
        'tips': 0.0,
      };
    }).toList();

    await file.writeAsString(jsonEncode(migratedAppointments));
  }

  await prefs.setBool('appointmentsMigrated', true);
}
