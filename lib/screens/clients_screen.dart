import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/appointment.dart';
import '../models/client.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<Appointment> appointments = [];
  List<Appointment> filteredAppointments = [];
  List<Client> clients = [];
  String? _selectedClient;
  List<String> _clientNames = [];
  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sortNewestFirst = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null).then((_) {
      _loadData();
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _appointmentsFile async {
    final path = await _localPath;
    return File('$path/appointments.json');
  }

  Future<File> get _clientsFile async {
    final path = await _localPath;
    return File('$path/clients.json');
  }

  Future<void> _loadData() async {
    try {
      // Load appointments
      final appointmentsFile = await _appointmentsFile;
      if (await appointmentsFile.exists()) {
        final contents = await appointmentsFile.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        appointments = jsonData
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        appointments = [];
      }

      // Load clients
      final clientsFile = await _clientsFile;
      if (await clientsFile.exists()) {
        final contents = await clientsFile.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        clients = jsonData
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        clients = [];
      }

      setState(() {
        _clientNames = appointments
            .map((a) => a.name)
            .toSet()
            .toList()
          ..sort();
        filteredAppointments = appointments;
        _selectedClient = _clientNames.isNotEmpty ? _clientNames[0] : null;
        _clientController.text = _selectedClient ?? '';
      });
    } catch (e) {
      setState(() {
        appointments = [];
        clients = [];
        _clientNames = [];
        _selectedClient = null;
        filteredAppointments = [];
        _clientController.text = '';
      });
    }
  }

  Future<void> _saveClientPhone(String clientName, String? phone) async {
    try {
      final clientsFile = await _clientsFile;
      final existingClient = clients.firstWhere(
        (c) => c.name == clientName,
        orElse: () => Client(name: clientName),
      );
      final updatedClient = Client(name: clientName, phone: phone);
      if (existingClient.name == clientName) {
        clients.remove(existingClient);
      }
      if (phone != null && phone.isNotEmpty) {
        clients.add(updatedClient);
      }
      await clientsFile.writeAsString(
          jsonEncode(clients.map((e) => e.toJson()).toList()));
      setState(() {
        clients = clients;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении номера: $e')),
      );
    }
  }

  String? _getClientPhone(String clientName) {
    final client = clients.firstWhere(
      (c) => c.name == clientName,
      orElse: () => Client(name: clientName),
    );
    return client.phone;
  }

  Future<void> _makePhoneCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Номер телефона не указан')),
      );
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось совершить звонок')),
      );
    }
  }

  void _showPhoneDialog(String clientName) {
    _phoneController.text = _getClientPhone(clientName) ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Номер телефона'),
          content: TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              hintText: 'Введите номер телефона',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _saveClientPhone(clientName, _phoneController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  List<Appointment> _getAppointmentsForClient(String clientName) {
    return filteredAppointments
        .where((appointment) => appointment.name == clientName)
        .toList()
      ..sort((a, b) => _sortNewestFirst
          ? b.dateTime.compareTo(a.dateTime)
          : a.dateTime.compareTo(b.dateTime));
  }

  Map<String, dynamic> _calculateStats(String clientName) {
    final clientAppointments = _getAppointmentsForClient(clientName);
    final visitCount = clientAppointments.length;
    final totalEarnings =
        clientAppointments.fold<double>(0.0, (sum, app) => sum + app.earnings);
    return {'visitCount': visitCount, 'totalEarnings': totalEarnings};
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'ru');
    final stats = _selectedClient != null
        ? _calculateStats(_selectedClient!)
        : {'visitCount': 0, 'totalEarnings': 0.0};
    final phone = _selectedClient != null ? _getClientPhone(_selectedClient!) : null;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _clientNames.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedClient = selection;
                  _clientController.text = selection;
                  filteredAppointments = appointments
                      .where((appointment) => appointment.name == _selectedClient)
                      .toList();
                });
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Sync the provided controller with our _clientController
                if (fieldTextEditingController.text != _clientController.text) {
                  fieldTextEditingController.text = _clientController.text;
                }
                _clientController.addListener(() {
                  if (_clientController.text != fieldTextEditingController.text) {
                    fieldTextEditingController.text = _clientController.text;
                  }
                });
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Выберите или введите имя клиента',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: _clientController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _clientController.clear();
                                fieldTextEditingController.clear();
                                _selectedClient = null;
                                filteredAppointments = appointments;
                              });
                            },
                          )
                        : null,
                  ),
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.event_available, color: Colors.blue, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Посещений',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${stats['visitCount']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Итого',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${stats['totalEarnings'].toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Телефон',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              phone ?? 'Не указан',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            if (phone != null)
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.green),
                                onPressed: () => _makePhoneCall(phone),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_selectedClient != null)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPhoneDialog(_selectedClient!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _sortNewestFirst = !_sortNewestFirst;
                    });
                  },
                  icon: Icon(
                    _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 18,
                  ),
                  label: Text(
                    _sortNewestFirst ? 'От новых к старым' : 'От старых к новым',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _selectedClient == null
                  ? const Center(child: Text('Выберите клиента'))
                  : _getAppointmentsForClient(_selectedClient!).isEmpty
                      ? const Center(child: Text('Нет записей для этого клиента'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Дата')),
                              DataColumn(label: Text('Услуга')),
                              DataColumn(label: Text('Сумма')),
                            ],
                            rows: _getAppointmentsForClient(_selectedClient!)
                                .map((appointment) {
                              return DataRow(cells: [
                                DataCell(
                                    Text(dateFormat.format(appointment.dateTime))),
                                DataCell(Text(appointment.service)),
                                DataCell(Text(
                                    '${appointment.earnings.toStringAsFixed(0)} ₽')),
                              ]);
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clientController.dispose();
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}