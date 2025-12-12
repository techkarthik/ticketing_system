import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    try {
      final userData = await _authService.getUser(token);
      _user = userData;
      _token = token;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      // Token probably invalid/expired
      return false;
    }
  }

  Future<void> login(String username, String password, bool rememberMe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      
      _isAuthenticated = true;
      _user = response['user'];
      
      final token = response['token'];
      _token = token; // Critical fix: store token in memory
      if (rememberMe) {
         await _storage.write(key: 'jwt_token', value: token);
         final prefs = await SharedPreferences.getInstance();
         prefs.setString('userData', username); // Marker
      }

    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('Not authenticated');
    await _authService.changePassword(token, oldPassword, newPassword);
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    // Critical Fix: Use in-memory token first, fallback to storage if needed (but memory is preferred)
    if (_token == null) throw Exception('Not authenticated (No Token in Memory)');
    await _authService.addUser(_token!, userData);
  }

  Future<List<dynamic>> fetchAllUsers() async {
    // Ensure token is present
    final token = _token ?? await _storage.read(key: 'jwt_token');
    if (token == null) return [];
    
    try {
      return await _authService.getAllUsers(token);
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final token = _token ?? await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('Not authenticated');
    
    await _authService.updateUser(token, id, data);
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    await _storage.delete(key: 'jwt_token');
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}
