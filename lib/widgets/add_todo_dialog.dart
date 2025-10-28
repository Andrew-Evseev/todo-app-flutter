import 'package:flutter/material.dart';

// StatelessWidget - так как диалог не меняет свое состояние
class AddTodoDialog extends StatefulWidget {
  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  // Контроллеры для текстовых полей
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Добавить новую задачу'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Занимает только необходимое место
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Что нужно сделать?', // Подсказка над полем
              hintText: 'Например: Купить молоко', // Подсказка внутри поля
              border: OutlineInputBorder(), // Рамка вокруг поля
            ),
            autofocus: true, // Автоматически фокусироваться на этом поле
          ),
          SizedBox(height: 16), // Отступ между полями
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Описание (необязательно)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3, // Многострочное поле
          ),
        ],
      ),
      actions: [
        // Кнопка отмены
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Закрывает диалог
          },
          child: Text('Отмена'),
        ),
        // Кнопка сохранения
        ElevatedButton(
          onPressed: () {
            // Проверяем, что поле заголовка не пустое
            if (_titleController.text.trim().isNotEmpty) {
              // Возвращаем данные обратно в главный экран
              Navigator.of(context).pop({
                'title': _titleController.text.trim(),
                'description': _descriptionController.text.trim(),
              });
            }
          },
          child: Text('Добавить'),
        ),
      ],
    );
  }

  // Важно! Освобождаем ресурсы контроллеров
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}