import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylist_notebook/theme/theme.dart';
import 'package:stylist_notebook/ui/theme_provider.dart';
import 'theme_preview.dart';

class SettingsThemesScreen extends StatelessWidget {
  const SettingsThemesScreen({super.key});

  ThemeData _getThemeData(String themeName) {
    ThemeData baseTheme;
    switch (themeName) {
      case 'light':
        baseTheme = createLightTheme();
        break;
      case 'dark':
        baseTheme = createDarkTheme();
        break;
      case 'yellow':
        baseTheme = createYellowTheme();
        break;
      case 'purple':
        baseTheme = createPurpleTheme();
        break;
      case 'blue':
        baseTheme = createBlueTheme();
        break;
      case 'green':
        baseTheme = createGreenTheme();
        break;
      case 'red':
        baseTheme = createRedTheme();
        break;
      case 'dark_blue':
        baseTheme = createDarkBlueTheme();
        break;
      case 'light_blue':
        baseTheme = createLightBlueTheme();
        break;
      case 'normal_blue':
        baseTheme = createNormalBlueTheme();
        break;
      default:
        baseTheme = createLightTheme();
    }
    return baseTheme.copyWith(
      scaffoldBackgroundColor: themeName == 'black' ? AppColors.lightDark : AppColors.white,
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: themeName == 'black' ? AppColors.lightDark : AppColors.white,
      ),
    );
  }

  void _showThemePreview(BuildContext context, String themeName, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              Expanded(
                child: ThemePreview(themeData: _getThemeData(themeName)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Отмена',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        themeProvider.setTheme(themeName);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Применить',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeOptions = [
      {'name': 'yellow', 'label': 'Оранжевый', 'color': AppColors.yellow},
      {'name': 'purple', 'label': 'Сиреневый', 'color': AppColors.purpleAccent},
      {'name': 'blue', 'label': 'Синий', 'color': AppColors.blue},
      {'name': 'normal_blue', 'label': 'Синий №2', 'color': AppColors.normalBlue},
      {'name': 'dark_blue', 'label': 'Тёмно-синий', 'color': AppColors.darkBlue},
      {'name': 'light_blue', 'label': 'Светло-синий', 'color': AppColors.lightBlue},
      {'name': 'green', 'label': 'Зелёный', 'color': AppColors.green},
      {'name': 'red', 'label': 'Красный', 'color': AppColors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title:  const Text(
          'Темы',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите тему приложения',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true, // чтобы работал внутри Column
              physics: const NeverScrollableScrollPhysics(), // отключаем прокрутку внутри
              crossAxisCount: 3, // ровно 4 в строке
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: themeOptions.map((theme) {
                final isSelected = themeProvider.themeName == theme['name'];
                return GestureDetector(
                  onTap: () {
                    _showThemePreview(context, theme['name'] as String, themeProvider);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: theme['color'] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )

          ],
        ),
      ),
    );
  }
}