import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/master_service.dart';

class MasterProvider with ChangeNotifier {
  final MasterService _service = MasterService();

  List<dynamic> _branches = [];
  List<dynamic> _departments = [];
  bool _isLoading = false;

  List<dynamic> get branches => _branches;
  List<dynamic> get departments => _departments;
  bool get isLoading => _isLoading;

  Future<void> fetchBranches(String? token) async {
    if (token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _branches = await _service.getBranches(token);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBranch(String token, Map<String, dynamic> data) async {
    try {
      await _service.createBranch(token, data);
      await fetchBranches(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBranch(String token, String id, Map<String, dynamic> data) async {
    try {
      await _service.updateBranch(token, id, data);
      await fetchBranches(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchDepartments(String? token) async {
    if (token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _departments = await _service.getDepartments(token);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDepartment(String token, Map<String, dynamic> data) async {
    try {
      await _service.createDepartment(token, data);
      await fetchDepartments(token);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> updateDepartment(String token, String id, Map<String, dynamic> data) async {
    try {
      await _service.updateDepartment(token, id, data);
      await fetchDepartments(token);
    } catch (e) {
      rethrow;
    }
  }
}
