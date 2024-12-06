import 'package:flutter/material.dart';
import 'menu_drawer.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<String> clients = ['Клиент 1', 'Клиент 2'];

  Future<void> addClient(String clientName) async {
    setState(() {
      clients.add(clientName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Клиенты'),
      ),
      drawer: MenuDrawer(),
      body: clients.isEmpty
          ? Center(child: Text('Нет клиентов'))
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(clients[index]),
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
                title: Text('Новый клиент'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Введите ФИО клиента'),
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
                      addClient(controller.text);
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
