import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  /// Sign up a new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      final users = usersJson.map((json) => jsonDecode(json)).toList();
      
      // Check if email already exists
      final emailExists = users.any((user) => user['email'] == email);
      if (emailExists) {
        return {
          'success': false,
          'message': 'Email already registered. Please login instead.',
        };
      }
      
      // Create new user
      final newUser = {
        'name': name,
        'email': email,
        'password': password, // In production, hash this!
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // Add to users list
      users.add(newUser);
      
      // Save to storage
      await prefs.setStringList(
        _usersKey,
        users.map((user) => jsonEncode(user)).toList(),
      );
      
      // Set as current user (auto-login after signup)
      await prefs.setString(_currentUserKey, jsonEncode(newUser));
      
      return {
        'success': true,
        'message': 'Sign up successful!',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during sign up: $e',
      };
    }
  }

  /// Login an existing user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing users
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      final users = usersJson.map((json) => jsonDecode(json)).toList();
      
      // Find user with matching email and password
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );
      
      if (user.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email or password.',
        };
      }
      
      // Set as current user
      await prefs.setString(_currentUserKey, jsonEncode(user));
      
      return {
        'success': true,
        'message': 'Login successful!',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during login: $e',
      };
    }
  }

  /// Get current logged-in user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
