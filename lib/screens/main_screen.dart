import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'menu_drawer.dart';
import 'appointment.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Appointment> appointments = [];
  List<DateTime> holidays = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime focusedDate = DateTime.now();
  DateTime? calendarSelectedDate;

  @override
  void initState() {
    super.initState();
    calendarSelectedDate = DateTime.now();
    initializeDateFormatting('ru', null).then((_) {
      loadAppointments();
      loadHolidays();
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/appointments.json');
  }

  Future<File> get _holidaysFile async {
    final path = await _localPath;
    return File('$path/holidays.json');
  }

  Future<void> loadAppointments() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        setState(() {
          appointments = jsonData.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
        });
      } else {
        setState(() {
          appointments = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      setState(() {
        appointments = [];
      });
    }
  }

  Future<void> loadHolidays() async {
    try {
      final file = await _holidaysFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        setState(() {
          holidays = jsonData.map((e) => DateTime.parse(e as String)).toList();
        });
      } else {
        setState(() {
          holidays = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading holidays: $e');
      setState(() {
        holidays = [];
      });
    }
  }

  Future<void> saveAppointments() async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode(appointments.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving appointments: $e');
    }
  }

  Future<void> saveHolidays() async {
    try {
      final file = await _holidaysFile;
      await file.writeAsString(jsonEncode(holidays.map((e) => e.toIso8601String()).toList()));
    } catch (e) {
      debugPrint('Error saving holidays: $e');
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    setState(() {
      appointments.add(appointment);
    });
    await saveAppointments();
  }

  Future<void> updateAppointment(int index, Appointment updatedAppointment) async {
    setState(() {
      appointments[index] = updatedAppointment;
    });
    await saveAppointments();
  }

  Future<void> deleteAppointment(int index) async {
    setState(() {
      appointments.removeAt(index);
    });
    await saveAppointments();
  }

  Future<void> toggleHoliday(DateTime day) async {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final hasAppointments = getAppointmentsForDay(normalizedDay).isNotEmpty;

    if (hasAppointments && !holidays.any((h) => h.year == normalizedDay.year && h.month == normalizedDay.month && h.day == normalizedDay.day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя отмечать как выходной день с записями')),
      );
      return;
    }

    setState(() {
      if (holidays.any((h) => h.year == normalizedDay.year && h.month == normalizedDay.month && h.day == normalizedDay.day)) {
        holidays.removeWhere((h) => h.year == normalizedDay.year && h.month == normalizedDay.month && h.day == normalizedDay.day);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выходной снят')),
        );
      } else {
        holidays.add(normalizedDay);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('День отмечен как выходной')),
        );
      }
    });
    await saveHolidays();
  }

  List<Appointment> getAppointmentsForDay(DateTime day) {
    var dayAppointments = appointments.where((appointment) {
      return appointment.dateTime.year == day.year &&
             appointment.dateTime.month == day.month &&
             appointment.dateTime.day == day.day;
    }).toList();
    dayAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return dayAppointments;
  }

  DateTime roundTimeToNearestInterval(DateTime time, int minuteInterval) {
    final minutes = time.minute;
    final roundedMinutes = (minutes / minuteInterval).round() * minuteInterval;
    return DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      roundedMinutes,
    );
  }

  String formatSelectedDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Сегодня';
    }
    return DateFormat('d MMMM y', 'ru').format(date);
  }

  void _showEarningsDialog(BuildContext context, Appointment appointment, int index) {
    TextEditingController earningsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить заработок'),
          content: TextField(
            controller: earningsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Введите сумму (₽)',
            ),
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
                final input = earningsController.text.replaceAll(',', '.');
                final earnings = double.tryParse(input) ?? 0.0;
                if (earnings >= 0) {
                  final updatedAppointment = Appointment(
                    name: appointment.name,
                    service: appointment.service,
                    dateTime: appointment.dateTime,
                    earnings: earnings,
                  );
                  updateAppointment(index, updatedAppointment);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите корректную сумму')),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void showAppointmentDialog(BuildContext context, {Appointment? appointment, int? index, DateTime? selectedDay}) {
    TextEditingController nameController = TextEditingController(text: appointment?.name ?? '');
    TextEditingController serviceController = TextEditingController(text: appointment?.service ?? '');

    setState(() {
      selectedDate = selectedDay ?? appointment?.dateTime ?? DateTime.now();
    });
    selectedTime = appointment != null ? TimeOfDay.fromDateTime(appointment.dateTime) : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(appointment == null ? 'Новая запись' : 'Редактировать запись'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(hintText: 'Введите имя'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: serviceController,
                        decoration: const InputDecoration(hintText: 'Введите услугу'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: TableCalendar(
                          locale: 'ru_RU',
                          firstDay: DateTime(2025),
                          lastDay: DateTime(2100),
                          focusedDay: selectedDate!,
                          currentDay: selectedDate,
                          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setDialogState(() {
                              selectedDate = selectedDay;
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              if (holidays.any((h) =>
                                  h.year == day.year &&
                                  h.month == day.month &&
                                  h.day == day.day)) {
                                return Container(
                                  margin: const EdgeInsets.all(4.0),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    day.day.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: roundTimeToNearestInterval(
                              appointment?.dateTime ?? DateTime.now(), 10),
                          use24hFormat: true,
                          minuteInterval: 10,
                          onDateTimeChanged: (DateTime value) {
                            setDialogState(() {
                              selectedTime = TimeOfDay.fromDateTime(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (appointment != null)
                        TextButton(
                          onPressed: () {
                            deleteAppointment(index!);
                            Navigator.pop(context);
                          },
                          child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                        )
                      else
                        const SizedBox(width: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  serviceController.text.isNotEmpty &&
                                  selectedDate != null &&
                                  selectedTime != null) {
                                final newDateTime = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                );
                                final newAppointment = Appointment(
                                  name: nameController.text,
                                  service: serviceController.text,
                                  dateTime: newDateTime,
                                  earnings: appointment?.earnings ?? 0.0,
                                );
                                if (appointment == null) {
                                  addAppointment(newAppointment);
                                } else {
                                  updateAppointment(index!, newAppointment);
                                }
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Заполните все поля')),
                                );
                              }
                            },
                            child: Text(appointment == null ? 'Добавить' : 'Сохранить'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи'),
        backgroundColor: const Color.fromARGB(176, 94, 94, 253),
      ),
      drawer: MenuDrawer(appointments: appointments),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime(2025),
            lastDay: DateTime(2100),
            focusedDay: focusedDate,
            selectedDayPredicate: (day) => isSameDay(calendarSelectedDate, day),
            startingDayOfWeek: StartingDayOfWeek.monday, // Week starts from Monday
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                calendarSelectedDate = selectedDay;
                focusedDate = focusedDay;
              });
            },
            onDayLongPressed: (selectedDay, focusedDay) {
              toggleHoliday(selectedDay);
            },
            eventLoader: getAppointmentsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (holidays.any((h) => h.year == day.year && h.month == day.month && h.day == day.day)) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: const CalendarStyle(
              markersAlignment: Alignment.bottomRight,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formatSelectedDate(calendarSelectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: calendarSelectedDate == null
                ? const Center(child: Text('Выберите дату в календаре'))
                : holidays.any((h) =>
                        h.year == calendarSelectedDate!.year &&
                        h.month == calendarSelectedDate!.month &&
                        h.day == calendarSelectedDate!.day)
                    ? const Center(child: Text('Выходной день'))
                    : getAppointmentsForDay(calendarSelectedDate!).isEmpty
                        ? const Center(child: Text('Нет записей на этот день'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 75.0),
                            itemCount: getAppointmentsForDay(calendarSelectedDate!).length,
                            itemBuilder: (context, index) {
                              final appointment = getAppointmentsForDay(calendarSelectedDate!)[index];
                              final time = '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showAppointmentDialog(context,
                                                appointment: appointment,
                                                index: appointments.indexOf(appointment));
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$time - ${appointment.name} - ${appointment.service}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              if (appointment.earnings > 0)
                                                Text(
                                                  'Заработано: ${appointment.earnings.toStringAsFixed(0)} ₽',
                                                  style: const TextStyle(color: Colors.green),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                                        onPressed: () {
                                          _showEarningsDialog(context, appointment, appointments.indexOf(appointment));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: calendarSelectedDate != null &&
              !holidays.any((h) =>
                  h.year == calendarSelectedDate!.year &&
                  h.month == calendarSelectedDate!.month &&
                  h.day == calendarSelectedDate!.day)
          ? FloatingActionButton(
              onPressed: () {
                showAppointmentDialog(context, selectedDay: calendarSelectedDate);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}