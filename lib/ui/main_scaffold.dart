import 'package:flutter/material.dart';
import 'package:stylist_notebook/screens/clients_screen.dart';
import 'package:stylist_notebook/screens/settings/settings_screen.dart';
import 'package:stylist_notebook/screens/statistics_screen.dart';
import '../screens/recipes_screen.dart';
import '../screens/main_screen.dart';
import '../models/appointment.dart';

class MainScaffold extends StatefulWidget {
  final List<Appointment> appointments;

  const MainScaffold({super.key, required this.appointments});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2;

  List<Widget> get _screens => [
        const RecipesScreen(),
        const ClientsScreen(),
        const MainScreen(),
        const StatisticsScreen(),
        SettingsScreen(
          onBackupPathSelected: (path) {},
          appointments: widget.appointments,
          holidays: const [],
          clients: const [],
          expenses: const [],
          recipes: const [],
        ),
      ];

  List<BottomNavigationBarItem> get _navBarItems => const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Рецепты',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Клиенты',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.today),
          label: 'Записи',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Статистика',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Настройки',
        ),
      ];

  List<String> get _screenTitles => [
        'Рецепты',
        'Клиенты',
        'Записи',
        'Статистика',
        'Настройки',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
          _screenTitles[_currentIndex],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).appBarTheme.foregroundColor,
        unselectedItemColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.6),
        items: _navBarItems,
      ),
    );
  }
}