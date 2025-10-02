// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class LoadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/rat-static.png'), // Логотип
            SizedBox(height: 16),
            Text(
              'Hairdresser Notebook',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Ваш помощник для работы',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(), // Индикатор загрузки
          ],
        ),
      ),
    );
  }
}
