import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

// Màn hình danh sách công việc
class TaskListScreen extends StatefulWidget {
  final User currentUser;

  TaskListScreen({required this.currentUser});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  int? _selectedPriority;
  bool _isKanbanView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
            tooltip: _isKanbanView ? 'Chuyển sang danh sách' : 'Chuyển sang Kanban',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm công việc',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    hint: Text('Lọc theo trạng thái'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'To do', child: Text('Cần làm')),
                      DropdownMenuItem(value: 'In progress', child: Text('Đang tiến hành')),
                      DropdownMenuItem(value: 'Done', child: Text('Đã hoàn thành')),
                      DropdownMenuItem(value: 'Cancelled', child: Text('Đã hủy')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedPriority,
                    hint: Text('Lọc theo độ ưu tiên'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 1, child: Text('Thấp')),
                      DropdownMenuItem(value: 2, child: Text('Trung bình')),
                      DropdownMenuItem(value: 3, child: Text('Cao')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: DatabaseHelper.instance.searchTasks(
                widget.currentUser.id,
                widget.currentUser.role,
                query: _searchController.text,
                status: _selectedStatus,
                priority: _selectedPriority,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final tasks = snapshot.data!;
                if (_isKanbanView) {
                  final statusGroups = {
                    'To do': tasks.where((task) => task.status == 'To do').toList(),
                    'In progress': tasks.where((task) => task.status == 'In progress').toList(),
                    'Done': tasks.where((task) => task.status == 'Done').toList(),
                    'Cancelled': tasks.where((task) => task.status == 'Cancelled').toList(),
                  };
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: statusGroups.entries.map((entry) {
                        return Container(
                          width: 300,
                          margin: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                {
                                  'To do': 'Cần làm',
                                  'In progress': 'Đang tiến hành',
                                  'Done': 'Đã hoàn thành',
                                  'Cancelled': 'Đã hủy',
                                }[entry.key]!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: entry.value.length,
                                  itemBuilder: (context, index) {
                                    final task = entry.value[index];
                                    return TaskItem(
                                      task: task,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/task_detail',
                                          arguments: {'user': widget.currentUser, 'task': task},
                                        ).then((value) {
                                          if (value == true) setState(() {});
                                        });
                                      },
                                      onDelete: () async {
                                        await DatabaseHelper.instance.deleteTask(task.id);
                                        setState(() {});
                                      },
                                      onToggleComplete: () async {
                                        final updatedTask = Task(
                                          id: task.id,
                                          title: task.title,
                                          description: task.description,
                                          status: task.status,
                                          priority: task.priority,
                                          dueDate: task.dueDate,
                                          assignedTo: task.assignedTo,
                                          createdBy: task.createdBy,
                                          completed: !task.completed,
                                          createdAt: task.createdAt,
                                          updatedAt: DateTime.now(),
                                          category: task.category,
                                          attachments: task.attachments,
                                        );
                                        await DatabaseHelper.instance.updateTask(updatedTask);
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskItem(
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/task_detail',
                            arguments: {'user': widget.currentUser, 'task': task},
                          ).then((value) {
                            if (value == true) setState(() {});
                          });
                        },
                        onDelete: () async {
                          await DatabaseHelper.instance.deleteTask(task.id);
                          setState(() {});
                        },
                        onToggleComplete: () async {
                          final updatedTask = Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            status: task.status,
                            priority: task.priority,
                            dueDate: task.dueDate,
                            assignedTo: task.assignedTo,
                            createdBy: task.createdBy,
                            completed: !task.completed,
                            createdAt: task.createdAt,
                            updatedAt: DateTime.now(),
                            category: task.category,
                            attachments: task.attachments,
                          );
                          await DatabaseHelper.instance.updateTask(updatedTask);
                          setState(() {});
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/task_form',
            arguments: {'user': widget.currentUser, 'task': null},
          ).then((value) {
            if (value == true) setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}