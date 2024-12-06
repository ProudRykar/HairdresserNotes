import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(HairdresserApp());
}

class HairdresserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hairdresser Notebook',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: MainScreen(),
    );
  }
}
