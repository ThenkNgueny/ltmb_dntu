import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

// Màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập tên đăng nhập';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      print('Attempting login for username: ${_usernameController.text}');
                      final user = await DatabaseHelper.instance.getUser(_usernameController.text);
                      if (user != null && user.password == _passwordController.text) {
                        print('Login successful for user: ${user.username}, id: ${user.id}');
                        await DatabaseHelper.instance.updateLastActive(user.id);
                        Navigator.pushReplacementNamed(
                          context,
                          '/tasks',
                          arguments: user,
                        );
                      } else {
                        print('Login failed: Invalid username or password');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tên đăng nhập hoặc mật khẩu sai')),
                        );
                      }
                    } catch (e) {
                      print('Login error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi đăng nhập: $e')),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text('Đăng nhập'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}