import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'recipes_screen.dart';
import '../main.dart';
import 'appointment.dart';

class MenuDrawer extends StatefulWidget {
  final List<Appointment> appointments;

  const MenuDrawer({super.key, required this.appointments});

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateTodayStats(List<Appointment> appointments) {
    final today = DateTime.now();
    final todayAppointments = appointments.where((appointment) {
      return appointment.dateTime.year == today.year &&
             appointment.dateTime.month == today.month &&
             appointment.dateTime.day == today.day;
    }).toList();

    final clientCount = todayAppointments.length;
    final totalEarnings = todayAppointments.fold<double>(
        0.0, (sum, appointment) => sum + appointment.earnings);

    return {
      'clientCount': clientCount,
      'totalEarnings': totalEarnings,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    final stats = _calculateTodayStats(widget.appointments);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(176, 94, 94, 253),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Меню',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Builder(
                    builder: (context) {
                      final moneyColor = Theme.of(context).colorScheme.tertiary;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Клиентов сегодня: ${stats['clientCount']}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Заработок: ',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${stats['totalEarnings'].toStringAsFixed(2)} ₽',
                                  style: TextStyle(
                                    color: moneyColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    tooltip: isDarkMode ? 'Светлая тема' : 'Тёмная тема',
                    onPressed: () {
                      themeNotifier.value =
                          isDarkMode ? ThemeMode.light : ThemeMode.dark;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Записи'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Рецепты'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RecipesScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}