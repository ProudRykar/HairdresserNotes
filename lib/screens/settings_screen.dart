import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylist_notebook/screens/client.dart';
import 'package:stylist_notebook/screens/recipe.dart';
import 'package:stylist_notebook/screens/statistics_screen.dart';

import 'appointment.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onBackupPathSelected;
  final List<Appointment> appointments;
  final List<DateTime> holidays;
  final List<Client> clients;
  final List<Expense> expenses;
  final List<Recipe> recipes;

  const SettingsScreen({
    super.key,
    required this.onBackupPathSelected,
    required this.appointments,
    required this.holidays,
    required this.clients,
    required this.expenses,
    required this.recipes,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? backupPath;

  @override
  void initState() {
    super.initState();
    _loadBackupPath();
  }

  Future<void> _loadBackupPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backupPath = prefs.getString('backup_path');
    });
  }

  Future<void> _selectBackupFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        backupPath = selectedDirectory;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_path', selectedDirectory);
      widget.onBackupPathSelected(selectedDirectory);
    }
  }

  Future<void> _createBackup() async {
    if (backupPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите папку для бэкапа')),
      );
      return;
    }

    try {
      final backupDir = Directory(path.join(backupPath!, 'backup_${DateTime.now().millisecondsSinceEpoch}'));
      await backupDir.create(recursive: true);

      final appointmentsFile = File(path.join(backupDir.path, 'appointments.json'));
      await appointmentsFile.writeAsString(jsonEncode(widget.appointments.map((e) => e.toJson()).toList()));

      final holidaysFile = File(path.join(backupDir.path, 'holidays.json'));
      await holidaysFile.writeAsString(jsonEncode(widget.holidays.map((e) => e.toIso8601String()).toList()));

      final clientsFile = File(path.join(backupDir.path, 'clients.json'));
      await clientsFile.writeAsString(jsonEncode(widget.clients.map((e) => e.toJson()).toList()));

      final expensesFile = File(path.join(backupDir.path, 'expenses.json'));
      await expensesFile.writeAsString(jsonEncode(widget.expenses.map((e) => e.toJson()).toList()));

      final recipesFile = File(path.join(backupDir.path, 'recipes.json'));
      await recipesFile.writeAsString(jsonEncode(widget.recipes.map((e) => e.toJson()).toList()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бэкап успешно создан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании бэкапа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color.fromARGB(176, 94, 94, 253),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Выберите папку для бэкапа'),
              subtitle: Text(backupPath ?? 'Не выбрано'),
              trailing: ElevatedButton(
                onPressed: _selectBackupFolder,
                child: const Text('Выбрать'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createBackup,
              child: const Text('Создать бэкап'),
            ),
          ],
        ),
      ),
    );
  }
}