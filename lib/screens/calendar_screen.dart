import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'menu_drawer.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
      ),
      drawer: const MenuDrawer(),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDate = selected;
              });
            },
          ),
          Expanded(
            child: Center(
              child: Text('Записи на ${selectedDate.toLocal()}'),
            ),
          ),
        ],
      ),
    );
  }
}
