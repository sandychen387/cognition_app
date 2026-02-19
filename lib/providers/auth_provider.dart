// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;
  final String? name;

  User({
    required this.id,
    required this.email,
    this.name,
  });
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  bool get isAuthenticated => _currentUser != null;

  // 模拟登录（实际应该接入Supabase Auth）
  Future<bool> signIn(String email, String password) async {
    // TODO: 接入Supabase Auth
    _currentUser = User(
      id: 'test-user-id',
      email: email,
      name: 'Test User',
    );
    notifyListeners();
    return true;
  }

  // 模拟登出
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }
}