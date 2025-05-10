import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

// Widget hiển thị một công việc
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  TaskItem({
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onToggleComplete,
  });

  // Ánh xạ giữa giá trị tiếng Anh (lưu trữ) và tiếng Việt (hiển thị)
  final Map<String, String> _statusDisplayMap = {
    'To do': 'Cần làm',
    'In progress': 'Đang tiến hành',
    'Done': 'Đã hoàn thành',
    'Cancelled': 'Đã hủy',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            Text('Trạng thái: ${_statusDisplayMap[task.status] ?? task.status}'),
            if (task.dueDate != null)
              Text('Hạn: ${DateFormat.yMd().format(task.dueDate!)}'),
            if (task.category != null) Text('Danh mục: ${task.category}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.priority == 3)
              Icon(Icons.warning, color: Colors.red),
            if (task.priority == 2)
              Icon(Icons.warning, color: Colors.yellow),
            IconButton(
              icon: Icon(
                task.completed ? Icons.check_circle : Icons.check_circle_outline,
                color: task.completed ? Colors.green : null,
              ),
              onPressed: onToggleComplete,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}