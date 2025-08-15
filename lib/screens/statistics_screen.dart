import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:stylist_notebook/theme/theme.dart';
import '../models/appointment.dart';
import '../models/expense.dart';

class MonthlyStats {
  final DateTime month;
  final double earnings;
  final double expenses;
  final int _clientCount;

  MonthlyStats({
    required this.month,
    required this.earnings,
    required this.expenses,
    required int clientCount,
  }) : _clientCount = clientCount;

  int get clientCount => _clientCount;
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Appointment> appointments = [];
  List<Expense> expenses = [];
  List<MonthlyStats> monthlyStats = [];
  int _currentMonthIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    initializeDateFormatting('ru', null).then((_) {
      _loadData();
    });
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? _currentMonthIndex;
      if (newIndex != _currentMonthIndex) {
        setState(() {
          _currentMonthIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _appointmentsFile async {
    final path = await _localPath;
    return File('$path/appointments.json');
  }

  Future<File> get _expensesFile async {
    final path = await _localPath;
    return File('$path/expenses.json');
  }

  Future<void> _loadData() async {
    try {
      final appointmentsFile = await _appointmentsFile;
      if (await appointmentsFile.exists()) {
        final contents = await appointmentsFile.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        appointments = jsonData
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final expensesFile = await _expensesFile;
      if (await expensesFile.exists()) {
        final contents = await expensesFile.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        expenses = jsonData
            .map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _calculateMonthlyStats();
    } catch (e) {
      if (mounted) {
        setState(() {
          appointments = [];
          expenses = [];
          monthlyStats = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    }
  }

  Future<void> _saveExpenses() async {
    try {
      final file = await _expensesFile;
      await file.writeAsString(jsonEncode(expenses.map((e) => e.toJson()).toList()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения расходов: $e')),
        );
      }
    }
  }

  void _calculateMonthlyStats() {
    final Map<String, MonthlyStats> statsMap = {};

    for (var appointment in appointments) {
      final monthKey =
          '${appointment.dateTime.year}-${appointment.dateTime.month.toString().padLeft(2, '0')}';
      if (!statsMap.containsKey(monthKey)) {
        statsMap[monthKey] = MonthlyStats(
          month: DateTime(appointment.dateTime.year, appointment.dateTime.month, 1),
          earnings: 0.0,
          expenses: 0.0,
          clientCount: 0,
        );
      }
      statsMap[monthKey] = MonthlyStats(
        month: statsMap[monthKey]!.month,
        earnings: statsMap[monthKey]!.earnings + appointment.earnings + appointment.tips,
        expenses: statsMap[monthKey]!.expenses,
        clientCount: statsMap[monthKey]!._clientCount + 1,
      );
    }

    for (var expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (!statsMap.containsKey(monthKey)) {
        statsMap[monthKey] = MonthlyStats(
          month: DateTime(expense.date.year, expense.date.month, 1),
          earnings: 0.0,
          expenses: 0.0,
          clientCount: 0,
        );
      }
      statsMap[monthKey] = MonthlyStats(
        month: statsMap[monthKey]!.month,
        earnings: statsMap[monthKey]!.earnings,
        expenses: statsMap[monthKey]!.expenses + expense.amount,
        clientCount: statsMap[monthKey]!._clientCount,
      );
    }

    final List<MonthlyStats> sortedStats = statsMap.values.toList()
      ..sort((a, b) => b.month.compareTo(a.month));

    final List<MonthlyStats> finalStats = [];
    for (var stat in sortedStats) {
      final uniqueClients = <String>{};
      for (var appointment in appointments) {
        if (appointment.dateTime.year == stat.month.year &&
            appointment.dateTime.month == stat.month.month) {
          uniqueClients.add(appointment.name);
        }
      }
      finalStats.add(MonthlyStats(
        month: stat.month,
        earnings: stat.earnings,
        expenses: stat.expenses,
        clientCount: uniqueClients.length,
      ));
    }

    if (mounted) {
      setState(() {
        monthlyStats = finalStats;
        if (monthlyStats.isNotEmpty) {
          final now = DateTime.now();
          final currentYearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
          _currentMonthIndex = monthlyStats.indexWhere((stat) =>
              '${stat.month.year}-${stat.month.month.toString().padLeft(2, '0')}' ==
              currentYearMonth);
          _currentMonthIndex = _currentMonthIndex != -1 ? _currentMonthIndex : 0;
          _pageController.dispose();
          _pageController = PageController(initialPage: _currentMonthIndex);
        }
      });
    }
  }

  void _showExpenseDialog(BuildContext context, {Expense? expense, int? index}) {
    TextEditingController amountController =
        TextEditingController(text: expense?.amount.toString() ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: expense?.description ?? '');
    DateTime selectedDate = expense?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                expense == null ? 'Новый расход' : 'Редактировать расход',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Введите сумму (₽)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Введите описание',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: selectedDate,
                          use24hFormat: true,
                          onDateTimeChanged: (DateTime value) {
                            setDialogState(() {
                              selectedDate = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (expense != null)
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              expenses.removeAt(index!);
                            });
                            _saveExpenses();
                            _calculateMonthlyStats();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                      )
                    else
                      const SizedBox.shrink(),
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
                            final amount = double.tryParse(
                                    amountController.text.replaceAll(',', '.')) ??
                                0.0;
                            if (amount > 0 && descriptionController.text.isNotEmpty) {
                              final newExpense = Expense(
                                date: selectedDate,
                                amount: amount,
                                description: descriptionController.text,
                              );
                              if (mounted) {
                                setState(() {
                                  if (expense == null) {
                                    expenses.add(newExpense);
                                  } else {
                                    expenses[index!] = newExpense;
                                  }
                                });
                                _saveExpenses();
                                _calculateMonthlyStats();
                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Заполните сумму и описание')),
                              );
                            }
                          },
                          child: Text(expense == null ? 'Добавить' : 'Сохранить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn(IconData icon, String label, double value, Color color, {bool isBold = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthStatsCard(MonthlyStats stat) {
    final profit = stat.earnings - stat.expenses;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 440;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Статистика за месяц',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height:  12),
                if (isNarrow)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatColumn(
                              Icons.account_balance_wallet,
                              'Доход (₽)',
                              stat.earnings,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatColumn(
                              Icons.payment,
                              'Расходы (₽)',
                              stat.expenses,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatColumn(
                              Icons.trending_up,
                              'Прибыль (₽)',
                              profit,
                              profit >= 0 ? Colors.blue : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatColumn(
                              Icons.people,
                              'Клиенты',
                              stat.clientCount.toDouble(),
                              Colors.black87,
                              isBold: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn(
                        Icons.account_balance_wallet,
                        'Доход (₽)',
                        stat.earnings,
                        Colors.green,
                      ),
                      _buildStatColumn(
                        Icons.payment,
                        'Расходы (₽)',
                        stat.expenses,
                        Colors.red,
                      ),
                      _buildStatColumn(
                        Icons.trending_up,
                        'Прибыль (₽)',
                        profit,
                        profit >= 0 ? Colors.blue : Colors.red,
                      ),
                      _buildStatColumn(
                        Icons.people,
                        'Клиенты',
                        stat.clientCount.toDouble(),
                        Colors.black87,
                        isBold: false,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBarChart(MonthlyStats stat) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Отчётный график',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (stat.earnings > stat.expenses ? stat.earnings : stat.expenses) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = rod.toY.toStringAsFixed(0);
                        final type = rodIndex == 0 ? 'Доход' : 'Расход';
                        return BarTooltipItem(
                          '$type: $value ₽',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt() == 0 ? 'Доход' : 'Расход',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: stat.earnings,
                          color: Colors.green,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: stat.expenses,
                          color: Colors.red,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(MonthlyStats stat) {
    final dateFormat = DateFormat('LLLL yyyy', 'ru');
    final filteredExpenses = expenses
        .where((e) => e.date.year == stat.month.year && e.date.month == stat.month.month)
        .toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Расходы за месяц',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            filteredExpenses.isEmpty
                ? const Center(child: Text('Нет расходов'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          title: Text(
                            expense.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Дата: ${dateFormat.format(expense.date)}\nСумма: ${expense.amount.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showExpenseDialog(context,
                                  expense: expense, index: expenses.indexOf(expense));
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('LLLL yyyy', 'ru');

    return Scaffold(
      body: monthlyStats.isEmpty
          ? const Center(child: Text('Нет данных для отображения'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left, size: 30),
                        onPressed: _currentMonthIndex < monthlyStats.length - 1
                            ? () {
                                _pageController.animateToPage(
                                  _currentMonthIndex + 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                      Text(
                        monthlyStats.isNotEmpty
                            ? dateFormat.format(monthlyStats[_currentMonthIndex].month)
                            : '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right, size: 30),
                        onPressed: _currentMonthIndex > 0
                            ? () {
                                _pageController.animateToPage(
                                  _currentMonthIndex - 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    reverse: true,
                    itemCount: monthlyStats.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentMonthIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final stat = monthlyStats[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildMonthStatsCard(stat),
                            const SizedBox(height: 16),
                            _buildBarChart(stat),
                            const SizedBox(height: 16),
                            _buildExpensesList(stat),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExpenseDialog(context);
        },
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}