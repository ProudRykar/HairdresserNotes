import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'calendar_screen.dart';
import 'clients_screen.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.pink),
            child: Text(
              'Меню',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.today),
            title: Text('Сегодня'),
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => MainScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Календарь'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Клиенты'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ClientsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
