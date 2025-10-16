// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylist_notebook/models/appointment.dart';
import 'package:stylist_notebook/models/client.dart';
import 'package:stylist_notebook/models/expense.dart';
import 'package:stylist_notebook/models/recipe.dart';
import 'package:stylist_notebook/screens/settings/src/themes_screen.dart';
import 'src/backup_screen.dart';
import 'package:stylist_notebook/ui/theme_provider.dart';

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

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        children: [
          _buildCard(
            context: context,
            icon: Icons.backup,
            title: 'Бэкапы',
            subtitle: 'Восстановить или создать бэкап',
            color: Theme.of(context).colorScheme.primary,
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
          _buildCard(
            context: context,
            icon: Icons.color_lens,
            title: 'Темы',
            subtitle: 'Выбрать тему приложения',
            color: Theme.of(context).colorScheme.primary,
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
    );
  }
}
