import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Основной цвет приложения
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(), // Первый экран при запуске
      debugShowCheckedModeBanner: false, // Убираем баннер DEBUG
    );
  }
}
