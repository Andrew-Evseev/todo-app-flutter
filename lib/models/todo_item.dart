import 'dart:convert';

class TodoItem {
  final String id;
  String title;
  String description;
  final DateTime createdAt;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '', // Добавляем значения по умолчанию
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(), // Значение по умолчанию
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Добавим метод для отладки
  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, completed: $isCompleted)';
  }
}