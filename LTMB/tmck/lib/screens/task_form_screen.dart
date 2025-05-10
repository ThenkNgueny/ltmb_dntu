import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/task.dart';

// Màn hình thêm hoặc sửa công việc
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final User currentUser;

  TaskFormScreen({this.task, required this.currentUser});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _attachmentController = TextEditingController();
  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;
  String? _assignedTo;
  List<User> _users = [];
  List<String> _attachments = [];
  bool _isLoadingUsers = true;

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
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _categoryController.text = widget.task!.category ?? '';
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _assignedTo = widget.task!.assignedTo;
      _attachments = widget.task!.attachments ?? [];
    } else {
      _assignedTo = widget.currentUser.id;
      _dueDate = DateTime.now();
    }

    // Nếu là admin, lấy danh sách người dùng
    if (widget.currentUser.role == 'admin') {
      DatabaseHelper.instance.getAllUsers().then((users) {
        setState(() {
          _users = users;
          _isLoadingUsers = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoadingUsers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy danh sách người dùng: $error')),
        );
      });
    } else {
      _isLoadingUsers = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsers) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.task == null ? 'Thêm công việc' : 'Sửa công việc')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Thêm công việc' : 'Sửa công việc')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập tiêu đề';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mô tả';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Danh mục (tùy chọn)'),
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: _statusDisplayMap.keys
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(_statusDisplayMap[status]!),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Trạng thái'),
                ),
                DropdownButtonFormField<int>(
                  value: _priority,
                  items: [
                    DropdownMenuItem(value: 1, child: Text('Thấp')),
                    DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Độ ưu tiên'),
                ),
                ListTile(
                  title: Text(_dueDate == null
                      ? 'Chọn ngày đến hạn'
                      : DateFormat.yMd().format(_dueDate!)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dueDate = pickedDate;
                      });
                    }
                  },
                ),
                if (widget.currentUser.role == 'admin')
                  _users.isNotEmpty
                      ? DropdownButtonFormField<String>(
                    value: _assignedTo,
                    items: _users
                        .map((user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.username),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Gán cho'),
                  )
                      : Text('Không có người dùng nào để gán'),
                if (widget.currentUser.role != 'admin')
                  TextFormField(
                    initialValue: widget.currentUser.username,
                    decoration: InputDecoration(labelText: 'Gán cho'),
                    readOnly: true,
                  ),
                TextFormField(
                  controller: _attachmentController,
                  decoration: InputDecoration(
                    labelText: 'Link đính kèm (nhấn Thêm để lưu)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_attachmentController.text.isNotEmpty) {
                          setState(() {
                            _attachments.add(_attachmentController.text);
                            _attachmentController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                if (_attachments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._attachments
                          .asMap()
                          .entries
                          .map(
                            (entry) => ListTile(
                          title: Text(entry.value),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _attachments.removeAt(entry.key);
                              });
                            },
                          ),
                        ),
                      )
                          .toList(),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_dueDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Vui lòng chọn ngày đến hạn')),
                            );
                            return;
                          }
                          final now = DateTime.now();
                          final task = Task(
                            id: widget.task?.id ?? now.toString(),
                            title: _titleController.text,
                            description: _descriptionController.text,
                            status: _status,
                            priority: _priority,
                            dueDate: _dueDate,
                            assignedTo: _assignedTo,
                            createdBy: widget.currentUser.id,
                            completed: widget.task?.completed ?? false,
                            createdAt: widget.task?.createdAt ?? now,
                            updatedAt: now,
                            category: _categoryController.text.isEmpty ? null : _categoryController.text,
                            attachments: _attachments.isEmpty ? null : _attachments,
                          );
                          try {
                            if (widget.task == null) {
                              await DatabaseHelper.instance.insertTask(task);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Thêm công việc thành công')),
                              );
                            } else {
                              await DatabaseHelper.instance.updateTask(task);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Cập nhật công việc thành công')),
                              );
                            }
                            Navigator.pop(context, true);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi khi lưu công việc: $error')),
                            );
                          }
                        }
                      },
                      child: Text(widget.task == null ? 'Thêm' : 'Cập nhật'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Hủy'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}