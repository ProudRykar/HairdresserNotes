import 'package:flutter/material.dart';
import 'menu_drawer.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
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
        title: Text('Записи на сегодня'),
      ),
      drawer: MenuDrawer(),
      body: todayAppointments.isEmpty
          ? Center(child: Text('Нет записей на сегодня'))
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
                title: Text('Новая запись'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Введите запись'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      addAppointment(controller.text);
                      Navigator.pop(context);
                    },
                    child: Text('Добавить'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
