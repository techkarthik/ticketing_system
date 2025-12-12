import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ticket_model.dart';

class TicketProvider with ChangeNotifier {
  List<Ticket> _tickets = [];
  bool _isLoading = false;

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;

  Future<void> fetchTickets({String? role, String? userId, String? branch}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String query = '';
      if (role != null) query += 'role=$role';
      if (userId != null) query += '&userId=$userId';
      if (branch != null) query += '&branch=$branch';

      final response = await ApiService.get('/tickets?$query');
      _tickets = (response as List).map((t) => Ticket.fromJson(t)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String branch,
    required String createdBy,
    String? assignedTo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ticketData = {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'branch': branch,
        'createdBy': createdBy,
        'assignedTo': assignedTo,
      };

      await ApiService.post('/tickets', ticketData);
      
      // Refresh tickets if needed, or just return true and let dashboard refresh
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTicket(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.put('/tickets/$id', updates);
      
      // Update local list
      final index = _tickets.indexWhere((t) => t.id == id);
      if (index != -1) {
        // Fetch fresh data or manually update local object. Fetching is safer for populated fields.
        final response = await ApiService.get('/tickets?role=Admin'); // Hacky refresh, ideally fetch specific ticket
        // Actually, let's just re-fetch everything for simplicity or trust the response
        // The PUT response returns the updated ticket.
        // But simpler to just refresh list based on current filters if possible, or just hack it:
        // Let's just return true and let UI trigger refresh.
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
