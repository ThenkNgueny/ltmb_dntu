import 'package:flutter/material.dart';
import '../model/Note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;

  const NoteDetailScreen({
    Key? key,
    required this.note,
    required this.onEdit,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red.shade100;
      case 2:
        return Colors.orange.shade100;
      case 3:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: 'Chỉnh sửa ghi chú',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: _getPriorityColor(note.priority),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Tags
              if (note.tags != null && note.tags!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                  ))
                      .toList(),
                ),

              const SizedBox(height: 20),

              // Dates
              Text(
                'Tạo: ${_formatDate(note.createdAt)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                'Cập nhật: ${_formatDate(note.modifiedAt)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
