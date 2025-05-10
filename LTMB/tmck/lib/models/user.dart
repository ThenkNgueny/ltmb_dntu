// Định nghĩa mô hình User
class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String role; // Phân biệt admin hoặc user
  final String? avatar; // URL avatar
  final DateTime createdAt; // Thời gian tạo tài khoản
  final DateTime lastActive; // Thời gian hoạt động gần nhất

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
  });

  // Chuyển User thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }

  // Tạo User từ Map (kết quả từ SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      role: map['role'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
    );
  }
}