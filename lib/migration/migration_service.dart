import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> migrateClientsJson() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/clients.json');

  if (await file.exists()) {
    // Читаем существующий JSON
    final jsonString = await file.readAsString();
    final List<dynamic> clients = jsonDecode(jsonString);

    // Обновляем каждый объект, добавляя telegram_id
    final migratedClients = clients.map((client) {
      return {
        'name': client['name'],
        'phone': client['phone'],
        'telegram_id': '', // Пустое значение по умолчанию, можно заменить на другое
      };
    }).toList();

    // Сохраняем обновленные данные
    await file.writeAsString(jsonEncode(migratedClients));
  }
}