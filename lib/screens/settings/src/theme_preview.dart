import 'package:flutter/material.dart';
import 'package:stylist_notebook/theme/theme.dart';
import 'package:table_calendar/table_calendar.dart';

class ThemePreview extends StatelessWidget {
  final ThemeData themeData;

  const ThemePreview({super.key, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text(
            'Записи',
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: themeData.scaffoldBackgroundColor,
                    child: TableCalendar(
                      locale: 'ru_RU',
                      firstDay: DateTime(2025),
                      lastDay: DateTime(2100),
                      focusedDay: DateTime.now(),
                      selectedDayPredicate: (day) => isSameDay(DateTime.now(), day),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: themeData.textTheme.bodyMedium!,
                        selectedDecoration: BoxDecoration(
                          color: themeData.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: themeData.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: themeData.textTheme.titleMedium!,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Сегодня',
                      style: themeData.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          color: themeData.cardTheme.color,
                          elevation: themeData.cardTheme.elevation,
                          child: ListTile(
                            title: Text(
                              '10:00 - Анна - Стрижка',
                              style: themeData.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Заработано: 1500 ₽',
                              style: themeData.textTheme.bodySmall?.copyWith(
                                color: themeData.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // Устанавливаем "Записи" как активную вкладку
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeData.appBarTheme.backgroundColor,
          selectedItemColor: themeData.appBarTheme.foregroundColor,
          unselectedItemColor: themeData.appBarTheme.foregroundColor?.withOpacity(0.6),
          items: const [
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: themeData.appBarTheme.backgroundColor,
          foregroundColor: AppColors.white,
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }
}