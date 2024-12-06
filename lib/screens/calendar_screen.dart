import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'menu_drawer.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Календарь'),
      ),
      drawer: MenuDrawer(),
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
