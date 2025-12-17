import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static User? _currentUser;
  static String? _token;

  static User? get currentUser => _currentUser;
  static String? get token => _token;
  static bool get isLoggedIn => _currentUser != null && _token != null;
  static bool get isAdmin => _currentUser?.isContractor == true;

  static Future<void> loadUser() async {
    // Mock user for passwordless access
    _currentUser = User(
      id: 1,
      name: 'Admin User',
      email: 'admin@evatlas.com',
      phone: '5551234567',
      isContractor: true,
      profilePhotoUrl: null,
      createdAt: DateTime.now(),
    );
    _token = 'mock-token-for-passwordless-access';
    print('Mock Admin User loaded for passwordless access');
  }

  static Future<void> saveUser(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_user', json.encode(user.toJson()));
      await prefs.setString('admin_token', token);
      _currentUser = user;
      _token = token;
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_user');
      await prefs.remove('admin_token');
      _currentUser = null;
      _token = null;
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}