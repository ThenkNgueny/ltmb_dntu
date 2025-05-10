import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import '../models/user.dart';

// Màn hình chi tiết công việc
class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final User currentUser;

  TaskDetailScreen({required this.task, required this.currentUser});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  // Ánh xạ giữa giá trị tiếng Anh (lưu trữ) và tiếng Việt (hiển thị)
  final Map<String, String> _statusDisplayMap = {
    'To do': 'Cần làm',
    'In progress': 'Đang tiến hành',
    'Done': 'Đã hoàn thành',
    'Cancelled': 'Đã hủy',
  };

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _currentStatus) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedTask = Task(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        status: newStatus,
        priority: widget.task.priority,
        dueDate: widget.task.dueDate,
        assignedTo: widget.task.assignedTo,
        createdBy: widget.task.createdBy,
        completed: widget.task.completed,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(),
        category: widget.task.category,
        attachments: widget.task.attachments,
      );

      await DatabaseHelper.instance.updateTask(updatedTask);
      setState(() {
        _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
      // Thông báo cho TaskListScreen để làm mới danh sách
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/task_form',
                arguments: {'user': widget.currentUser, 'task': widget.task},
              ).then((value) {
                if (value == true) {
                  Navigator.pop(context, true); // Làm mới danh sách
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tiêu đề:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.task.title, style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.task.description),
              SizedBox(height: 10),
              Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(_statusDisplayMap[_currentStatus] ?? _currentStatus),
                  SizedBox(width: 10),
                  _isUpdating
                      ? CircularProgressIndicator()
                      : DropdownButton<String>(
                    value: _currentStatus,
                    items: _statusDisplayMap.keys
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_statusDisplayMap[status]!),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateStatus(value);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                widget.task.priority == 1 ? 'Thấp' : widget.task.priority == 2 ? 'Trung bình' : 'Cao',
              ),
              SizedBox(height: 10),
              if (widget.task.dueDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hạn hoàn thành:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat.yMd().format(widget.task.dueDate!)),
                  ],
                ),
              SizedBox(height: 10),
              if (widget.task.category != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.task.category!),
                  ],
                ),
              SizedBox(height: 10),
              FutureBuilder<User?>(
                future: DatabaseHelper.instance.getUserById(widget.task.createdBy),
                builder: (context, snapshot) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Người tạo:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        snapshot.hasData ? snapshot.data!.username : 'Không xác định',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              if (widget.task.assignedTo != null)
                FutureBuilder<User?>(
                  future: DatabaseHelper.instance.getUserById(widget.task.assignedTo!),
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gán cho:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          snapshot.hasData ? snapshot.data!.username : 'Không xác định',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  },
                ),
              SizedBox(height: 10),
              Text('Thời gian tạo:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(DateFormat.yMd().add_Hms().format(widget.task.createdAt)),
              SizedBox(height: 10),
              Text('Cập nhật lần cuối:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(DateFormat.yMd().add_Hms().format(widget.task.updatedAt)),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (widget.task.attachments != null && widget.task.attachments!.isNotEmpty)
                    ...widget.task.attachments!
                        .map((attachment) => ListTile(
                      title: Text(attachment),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mở link: $attachment')),
                        );
                      },
                    ))
                        .toList()
                  else
                    Text('Không có tệp đính kèm'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}