import 'package:flutter/material.dart';
import 'menu_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> todayAppointments = [];

  @override
  void initState() {
    super.initState();
    loadAppointmentsForToday();
  }

  Future<void> loadAppointmentsForToday() async {
    setState(() {
      todayAppointments = ['Пример записи 1', 'Пример записи 2'];
    });
  }

  Future<void> addAppointment(String appointment) async {
    setState(() {
      todayAppointments.add(appointment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи на сегодня'),
      ),
      drawer: const MenuDrawer(),
      body: todayAppointments.isEmpty
          ? const Center(child: Text('Нет записей на сегодня'))
          : ListView.builder(
              itemCount: todayAppointments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todayAppointments[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: const Text('Новая запись'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Введите запись'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      addAppointment(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Добавить'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
