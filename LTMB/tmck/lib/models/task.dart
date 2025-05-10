// Định nghĩa mô hình Task
class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final String? assignedTo;
  final String createdBy;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final List<String>? attachments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.assignedTo,
    required this.createdBy,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.attachments,
  });

  // Chuyển Task thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
      'attachments': attachments?.join(','),
    };
  }

  // Tạo Task từ Map (kết quả từ SQLite)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      priority: map['priority'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'],
      completed: map['completed'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      category: map['category'],
      attachments: map['attachments'] != null ? (map['attachments'] as String).split(',') : null,
    );
  }
}