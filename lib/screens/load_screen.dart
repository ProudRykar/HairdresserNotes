import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylist_notebook/ui/theme_provider.dart';

class LoadScreen extends StatelessWidget {
  const LoadScreen({super.key});

  LinearGradient _getGradient(String themeName) {
    switch (themeName) {
      case 'yellow':
        return const LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFD54F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'purple':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'blue':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'dark_blue':
        return const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'light_blue':
        return const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'normal_blue':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'green':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'red':
        return const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFE57373)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default: // светлая тема
        return const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getGradient(themeProvider.themeName),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: const Text(
                  'Hairdresser Notebook',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваш помощник для работы',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
