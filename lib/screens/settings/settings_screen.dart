import 'package:flutter/material.dart';
import 'package:stylist_notebook/models/appointment.dart';
import 'package:stylist_notebook/models/client.dart';
import 'package:stylist_notebook/models/expense.dart';
import 'package:stylist_notebook/models/recipe.dart';
import 'package:stylist_notebook/screens/settings/src/themes_screen.dart';
import 'src/backup_screen.dart';

class SettingsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Бэкапы',
              ),
              subtitle: const Text(
                'Восстановить или создать бэкап',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsBackupScreen(
                      onBackupPathSelected: onBackupPathSelected,
                      appointments: appointments,
                      holidays: holidays,
                      clients: clients,
                      expenses: expenses,
                      recipes: recipes,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Темы',
              ),
              subtitle: const Text(
                'Выбрать тему приложения',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsThemesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}