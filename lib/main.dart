import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(HairdresserApp(key: GlobalKey()));
}

class HairdresserApp extends StatefulWidget {
  const HairdresserApp({super.key});

  @override
  State<HairdresserApp> createState() => _HairdresserAppState();
}

class _HairdresserAppState extends State<HairdresserApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hairdresser Notebook',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MainScreen(),
    );
  }
}
