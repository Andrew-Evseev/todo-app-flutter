import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class StorageService {
  static const String _todosKey = 'todos';

  Future<List<TodoItem>> loadTodos() async {
    print('🔄 StorageService: Начинаем загрузку задач...');
    
    final prefs = await SharedPreferences.getInstance();
    final String todosString = prefs.getString(_todosKey) ?? '[]';
    
    print('📥 StorageService: Получены данные из SharedPreferences: $todosString');
    print('📥 StorageService: Длина строки: ${todosString.length}');
    
    try {
      final List<dynamic> todosJson = json.decode(todosString);
      print('✅ StorageService: JSON декодирован успешно, элементов: ${todosJson.length}');
      
      final loadedTodos = todosJson.map((json) => TodoItem.fromMap(json)).toList();
      print('✅ StorageService: Успешно загружено ${loadedTodos.length} задач');
      
      // Выведем подробности о каждой задаче
      for (var todo in loadedTodos) {
        print('   - ${todo.title} (ID: ${todo.id})');
      }
      
      return loadedTodos;
    } catch (e) {
      print('❌ StorageService: Ошибка при декодировании JSON: $e');
      print('❌ StorageService: Данные которые не удалось декодировать: $todosString');
      return [];
    }
  }

  Future<void> saveTodos(List<TodoItem> todos) async {
    print('💾 StorageService: Начинаем сохранение ${todos.length} задач...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Проверим данные перед сохранением
    print('💾 StorageService: Данные для сохранения:');
    for (var todo in todos) {
      print('   - ${todo.title} (ID: ${todo.id}, completed: ${todo.isCompleted})');
    }
    
    final List<Map<String, dynamic>> todosMap = todos.map((todo) => todo.toMap()).toList();
    print('💾 StorageService: Данные преобразованы в Map: $todosMap');
    
    final String todosString = json.encode(todosMap);
    print('💾 StorageService: Данные преобразованы в JSON: $todosString');
    
    final bool success = await prefs.setString(_todosKey, todosString);
    
    if (success) {
      print('✅ StorageService: Данные успешно сохранены в SharedPreferences');
    } else {
      print('❌ StorageService: Ошибка при сохранении в SharedPreferences');
    }
  }
}