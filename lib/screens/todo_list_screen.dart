import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../services/storage_service.dart';
import '../widgets/add_todo_dialog.dart';

// Enum для типов фильтрации
enum TodoFilter { all, active, completed }

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todos = [];
  List<TodoItem> _filteredTodos = []; // Отфильтрованный список для отображения
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  TodoFilter _currentFilter = TodoFilter.all; // Текущий выбранный фильтр

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    print('🔄 Начинаем загрузку задач...');
    setState(() {
      _isLoading = true;
    });
    
    try {
      final todos = await _storageService.loadTodos();
      setState(() {
        _todos = todos;
        _applyFilter(); // Применяем фильтр после загрузки
        _isLoading = false;
      });
      print('✅ Загружено ${_todos.length} задач');
    } catch (e) {
      print('❌ Ошибка при загрузке: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Ошибка при загрузке задач');
    }
  }

  // Метод для применения текущего фильтра
  void _applyFilter() {
    switch (_currentFilter) {
      case TodoFilter.all:
        _filteredTodos = _todos;
        break;
      case TodoFilter.active:
        _filteredTodos = _todos.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        _filteredTodos = _todos.where((todo) => todo.isCompleted).toList();
        break;
    }
    print('🔍 Применен фильтр "$_currentFilter". Показано ${_filteredTodos.length} из ${_todos.length} задач');
  }

  // Метод для изменения фильтра
  void _changeFilter(TodoFilter filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _saveTodos() async {
    try {
      await _storageService.saveTodos(_todos);
    } catch (e) {
      print('❌ Ошибка при сохранении: $e');
      _showErrorSnackBar('Ошибка при сохранении задач');
    }
  }

  void _addTodo() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddTodoDialog(),
    );

    if (result != null) {
      final newTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title']!,
        description: result['description']!,
        createdAt: DateTime.now(),
      );

      setState(() {
        _todos.add(newTodo);
        _applyFilter(); // Обновляем фильтр после добавления
      });
      
      await _saveTodos();
      _showSuccessSnackBar('Задача "${result['title']}" добавлена!');
    }
  }

  void _deleteTodo(int index) {
    // Получаем задачу из отфильтрованного списка
    final deletedTodo = _filteredTodos[index];
    final originalIndex = _todos.indexOf(deletedTodo);
    
    setState(() {
      _todos.removeAt(originalIndex);
      _applyFilter(); // Обновляем фильтр после удаления
    });
    
    _saveTodos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${deletedTodo.title}" удалена'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            setState(() {
              _todos.insert(originalIndex, deletedTodo);
              _applyFilter();
            });
            _saveTodos();
          },
        ),
      ),
    );
  }

  void _toggleTodo(int index) {
    // Получаем задачу из отфильтрованного списка
    final todo = _filteredTodos[index];
    final originalIndex = _todos.indexOf(todo);
    
    setState(() {
      _todos[originalIndex].isCompleted = !_todos[originalIndex].isCompleted;
      _applyFilter(); // Обновляем фильтр после изменения статуса
    });
    _saveTodos();
  }

  // Вспомогательные методы для показа уведомлений
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Метод для получения текста заголовка в зависимости от фильтра
  String _getAppBarTitle() {
    switch (_currentFilter) {
      case TodoFilter.all:
        return 'Все задачи (${_todos.length})';
      case TodoFilter.active:
        final activeCount = _todos.where((todo) => !todo.isCompleted).length;
        return 'Активные задачи ($activeCount)';
      case TodoFilter.completed:
        final completedCount = _todos.where((todo) => todo.isCompleted).length;
        return 'Выполненные задачи ($completedCount)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()), // Динамический заголовок
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Выпадающее меню для выбора фильтра
          PopupMenuButton<TodoFilter>(
            onSelected: _changeFilter,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TodoFilter.all,
                child: Row(
                  children: [
                    Icon(Icons.list, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Все задачи'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.active,
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Активные'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Выполненные'),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загружаем ваши задачи...'),
                ],
              ),
            )
          : _buildTodoList(),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Добавить новую задачу', // Подсказка при долгом нажатии
      ),
    );
  }

  // Выносим построение списка в отдельный метод для чистоты кода
  Widget _buildTodoList() {
    if (_filteredTodos.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        // Статистика задач
        _buildStatsCard(),
        // Список задач
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTodos.length,
            itemBuilder: (context, index) {
              final todo = _filteredTodos[index];
              return _buildTodoItem(todo, index);
            },
          ),
        ),
      ],
    );
  }

  // Виджет для пустого состояния
  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (_currentFilter) {
      case TodoFilter.all:
        message = 'Пока нет задач';
        subtitle = 'Нажми + чтобы добавить первую задачу';
        icon = Icons.list;
        break;
      case TodoFilter.active:
        message = 'Нет активных задач';
        subtitle = 'Все задачи выполнены! 🎉';
        icon = Icons.celebration;
        break;
      case TodoFilter.completed:
        message = 'Нет выполненных задач';
        subtitle = 'Выполненные задачи появятся здесь';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка со статистикой
  Widget _buildStatsCard() {
    final total = _todos.length;
    final completed = _todos.where((todo) => todo.isCompleted).length;
    final active = total - completed;
    final percent = total > 0 ? (completed / total * 100).round() : 0;

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Всего', total, Icons.list),
            _buildStatItem('Активные', active, Icons.radio_button_unchecked),
            _buildStatItem('Выполнено', completed, Icons.check_circle),
            _buildStatItem('Прогресс', percent, Icons.percent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Элемент списка задач
  Widget _buildTodoItem(TodoItem todo, int index) {
    return Dismissible(
      key: Key(todo.id), // Уникальный ключ для анимации dismiss
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (_) => _deleteTodo(index),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: todo.isCompleted ? Colors.grey[50] : Colors.white,
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => _toggleTodo(index),
            shape: CircleBorder(),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              color: todo.isCompleted ? Colors.grey : Colors.black,
              fontWeight: todo.isCompleted ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          subtitle: todo.description.isNotEmpty 
              ? Text(
                  todo.description,
                  style: TextStyle(
                    color: todo.isCompleted ? Colors.grey : Colors.black54,
                    fontStyle: todo.isCompleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ) 
              : null,
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTodo(index),
            tooltip: 'Удалить задачу',
          ),
          onTap: () => _toggleTodo(index),
        ),
      ),
    );
  }
}