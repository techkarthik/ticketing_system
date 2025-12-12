import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String _status;
  String? _assignedTo;
  bool _isEditing = false;
  bool _isLoading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _status = widget.ticket.status;
    _assignedTo = widget.ticket.assignedTo?.id;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.get('/master/users');
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _updateTicket() async {
    setState(() => _isLoading = true);
    try {
      final success = await Provider.of<TicketProvider>(context, listen: false)
          .updateTicket(widget.ticket.id, {
        'status': _status,
        'assignedTo': _assignedTo,
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket Updated')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update Failed')));
        }
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final canEdit = user?.role == 'Admin' || user?.role == 'Supervisor' || 
                   user?.id == widget.ticket.assignedTo?.id ||
                   user?.id == widget.ticket.createdBy;
    
    final canReassign = user?.role == 'Admin' || user?.role == 'Supervisor';

    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Priority Badges
            Row(
              children: [
                Chip(label: Text(widget.ticket.status), backgroundColor: Colors.blue[100]),
                const SizedBox(width: 8),
                Chip(label: Text(widget.ticket.priority), backgroundColor: Colors.orange[100]),
                const SizedBox(width: 8),
                Chip(label: Text(widget.ticket.category), backgroundColor: Colors.grey[200]),
              ],
            ),
            const SizedBox(height: 24),
            
            // Description
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.ticket.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),

            // Controls
            if (canEdit) ...[
              const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _status,
                isExpanded: true,
                items: ['Open', 'Pending', 'In Progress', 'Resolved', 'Closed', 'Rejected']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
            ],

            if (canReassign) ...[
               const Text('Reassign To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               DropdownButton<String>(
                value: _users.any((u) => u['_id'] == _assignedTo) ? _assignedTo : null,
                isExpanded: true,
                hint: const Text('Select User'),
                items: _users.map<DropdownMenuItem<String>>((u) {
                  return DropdownMenuItem(value: u['_id'], child: Text('${u['username']} (${u['role']})'));
                }).toList(),
                onChanged: (val) => setState(() => _assignedTo = val),
              ),
              const SizedBox(height: 24),
            ],

            if (canEdit || canReassign)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateTicket,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('UPDATE TICKET'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
