import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/task_detail_screen.dart';
import 'models/user.dart';
import 'models/task.dart';

// Tệp chính của ứng dụng
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        print('Navigating to: ${settings.name}, arguments: ${settings.arguments}');
        try {
          if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => LoginScreen());
          } else if (settings.name == '/register') {
            return MaterialPageRoute(builder: (context) => RegisterScreen());
          } else if (settings.name == '/tasks') {
            if (settings.arguments is User) {
              final user = settings.arguments as User;
              return MaterialPageRoute(builder: (context) => TaskListScreen(currentUser: user));
            } else {
              throw Exception('Invalid arguments for /tasks: Expected User, got ${settings.arguments}');
            }
          } else if (settings.name == '/task_form') {
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final user = args['user'] as User?;
              final task = args['task'] as Task?;
              if (user != null) {
                return MaterialPageRoute(
                  builder: (context) => TaskFormScreen(currentUser: user, task: task),
                );
              } else {
                throw Exception('Invalid arguments for /task_form: Missing user');
              }
            } else {
              throw Exception('Invalid arguments for /task_form: Expected Map<String, dynamic>, got ${settings.arguments}');
            }
          } else if (settings.name == '/task_detail') {
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final user = args['user'] as User?;
              final task = args['task'] as Task?;
              if (user != null && task != null) {
                return MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(currentUser: user, task: task),
                );
              } else {
                throw Exception('Invalid arguments for /task_detail: Missing user or task');
              }
            } else {
              throw Exception('Invalid arguments for /task_detail: Expected Map<String, dynamic>, got ${settings.arguments}');
            }
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text('Không tìm thấy màn hình: ${settings.name}')),
            ),
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text('Lỗi điều hướng: $e')),
            ),
          );
        }
      },
    );
  }
}