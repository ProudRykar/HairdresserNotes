// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:stylist_notebook/ui/main_scaffold.dart';
import 'package:stylist_notebook/models/appointment.dart';


class FirstLaunchScreen extends StatefulWidget {
  final List<Appointment> appointments;

  const FirstLaunchScreen({super.key, required this.appointments});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScaffold(appointments: widget.appointments),
        ),
      );
    }
  }

  final List<_IntroPage> _pages = [
    _IntroPage(
      icon: Icons.cut,
      title: 'Добро пожаловать в Hairdresser Notebook',
      description:
          'Это приложение создано для мастеров, которые хотят удобно управлять своими клиентами, записями и статистикой. '
          'Все данные хранятся локально на вашем устройстве.',
      previewBuilder: (context) => _buildWelcomePreview(context),
    ),
    _IntroPage(
      icon: Icons.people_alt_rounded,
      title: 'Экран клиентов',
      description:
          'Добавляйте и редактируйте клиентов, указывайте их контакты, а также быстро находите нужного человека по имени.',
      previewBuilder: (context) => _buildClientsPreview(context),
    ),
    _IntroPage(
      icon: Icons.event_note_rounded,
      title: 'Экран записей',
      description:
          'Создавайте и отслеживайте записи: дату, время, клиента и услугу. Всё сохраняется автоматически.',
      previewBuilder: (context) => _buildAppointmentsPreview(context),
    ),
    _IntroPage(
      icon: Icons.bar_chart_rounded,
      title: 'Экран статистики',
      description:
          'Анализируйте динамику своих записей и доходов. Улучшайте планирование и видьте результаты наглядно.',
      previewBuilder: (context) => _buildStatsPreview(context),
    ),
    _IntroPage(
      icon: Icons.settings_rounded,
      title: 'Настройки и темы',
      description:
          'Настройте внешний вид приложения под себя — выберите светлую или тёмную тему, управляйте резервным копированием данных.',
      previewBuilder: (context) => _buildSettingsPreview(context),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: page.previewBuilder(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
                  width: _currentPage == index ? 14 : 8,
                  height: _currentPage == index ? 14 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Продолжить' : 'Далее',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ——————————————————————————— Превью блоки ———————————————————————————

  static Widget _buildWelcomePreview(BuildContext context) {
    return const _PreviewCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cut, size: 50),
          SizedBox(height: 8),
          Text("Ваш персональный помощник стилиста",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  static Widget _buildClientsPreview(BuildContext context) {
    return const _PreviewCard(
      child: Column(
        children: [
          _ClientTile(
            name: "Анна",
            phone: "+7 999 123 45 67",
          ),
          _ClientTile(
            name: "Мария",
            phone: "+7 999 222 33 44",
          ),
          _ClientTile(
            name: "Ирина",
            phone: "+7 999 888 55 11",
          ),
        ],
      ),
    );
  }


  static Widget _buildAppointmentsPreview(BuildContext context) {
    return const _PreviewCard(
      child: Column(
        children: [
          _AppointmentTile(client: "Анна", date: "Сегодня, 14:00", service: "Окрашивание"),
          _AppointmentTile(client: "Мария", date: "Завтра, 10:00", service: "Стрижка"),
        ],
      ),
    );
  }

  static Widget _buildStatsPreview(BuildContext context) {
    return _PreviewCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_rounded, size: 48, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text("Всего записей: 42", style: Theme.of(context).textTheme.bodyLarge),
          Text("Доход за месяц: 84 000 ₽", style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  static Widget _buildSettingsPreview(BuildContext context) {
    final themeOptions = [
      {'label': 'Оранжевый', 'color': Colors.orange},
      {'label': 'Сиреневый', 'color': Colors.purpleAccent},
      {'label': 'Синий', 'color': Colors.blue},
    ];

    return _PreviewCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: themeOptions.map((theme) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26, width: 2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme['label'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.backup_rounded),
            title: Text("Резервное копирование"),
            subtitle: Text("Автоматически сохранять данные"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

// ——————————————————————————— Вспомогательные классы ———————————————————————————

class _IntroPage {
  final IconData icon;
  final String title;
  final String description;
  final Widget Function(BuildContext) previewBuilder;

  _IntroPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.previewBuilder,
  });
}

class _PreviewCard extends StatelessWidget {
  final Widget child;
  const _PreviewCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ClientTile extends StatelessWidget {
  final String name;
  final String phone;
  const _ClientTile({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(phone),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String client;
  final String date;
  final String service;
  const _AppointmentTile({required this.client, required this.date, required this.service});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.event_available_rounded),
      title: Text("$client — $service"),
      subtitle: Text(date),
    );
  }
}
