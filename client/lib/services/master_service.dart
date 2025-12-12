import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class MasterService {
  final String _baseUrl = Constants.baseUrl;

  Future<List<dynamic>> getBranches(String token) async {
    try {
      print('MasterService: Fetching branches with token: ${token.substring(0, 10)}...');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/branches'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> createBranch(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/branches'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create branch');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

   Future<List<dynamic>> getDepartments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/departments'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateBranch(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/branches/$id'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDepartment(String token, String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/departments/$id'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createDepartment(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/departments'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
         final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create department');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
