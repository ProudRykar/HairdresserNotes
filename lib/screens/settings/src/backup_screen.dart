import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylist_notebook/models/appointment.dart';
import 'package:stylist_notebook/models/client.dart';
import 'package:stylist_notebook/models/expense.dart';
import 'package:stylist_notebook/models/recipe.dart';

class SettingsBackupScreen extends StatefulWidget {
  final Function(String) onBackupPathSelected;
  final List<Appointment> appointments;
  final List<DateTime> holidays;
  final List<Client> clients;
  final List<Expense> expenses;
  final List<Recipe> recipes;

  const SettingsBackupScreen({
    super.key,
    required this.onBackupPathSelected,
    required this.appointments,
    required this.holidays,
    required this.clients,
    required this.expenses,
    required this.recipes,
  });

  @override
  State<SettingsBackupScreen> createState() => _SettingsBackupScreenState();
}

class _SettingsBackupScreenState extends State<SettingsBackupScreen> {
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
        SnackBar(
          content: Text(
            'Выберите папку для бэкапа',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
        SnackBar(
          content: Text(
            'Бэкап успешно создан',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при создании бэкапа: $e',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Бэкапы',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Папка для бэкапа',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                backupPath ?? 'Не выбрано',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: ElevatedButton(
                onPressed: _selectBackupFolder,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Выбрать'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createBackup,
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Создать бэкап'),
            ),
          ],
        ),
      ),
    );
  }
}