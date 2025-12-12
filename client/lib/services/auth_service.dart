import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  final String _baseUrl = Constants.baseUrl;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('AuthService: POST $_baseUrl/api/auth/login');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> changePassword(String token, String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> addUser(String token, Map<String, dynamic> userData) async {
    try {
      print('AuthService: Adding user with token: ${token.substring(0, 10)}...');
      print('AuthService: User Data: $userData');
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/add'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(userData),
      );

      print('AuthService: Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to add user');
      }
    } catch (e) {
      print('AuthService Error: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateUser(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, dynamic>> getUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
