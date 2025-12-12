import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket_model.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/side_menu.dart';
import '../tickets/ticket_detail_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  
  String? _selectedStatus;
  String? _selectedBranch; 
  List<String> _branches = [];
  
  final List<String> _statuses = ['Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _fetchBranches();
    
    // Defer initial fetch to allow context access for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTickets();
    });
  }

  Future<void> _fetchBranches() async {
    try {
      final response = await ApiService.get('/master/branches');
      if (mounted) {
        setState(() {
          _branches = (response as List).map((b) => b['name'].toString()).toList();
        });
      }
    } catch (e) {
      print('Error fetching branches: $e');
    }
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      String query = 'role=${user.role}&userId=${user.id}';
      
      // For Admin, 'branch' param serves as filter.
      // For others, their branch context is usually implicit or passed as 'branch' param in dashboard.
      // But here we want to layer on the filter.
      // Backend Logic Recap: 
      // if (Admin && branch) -> filter.branch = branch.
      // if (Supervisor) -> checks req.query.branch for their own branch context.
      
      // If user is Staff/Supervisor, they can't filter by OTHER branches anyway.
      // But if they filter by THEIR branch, it's redundant but fine.
      
      // If Admin:
      if (user.role == 'Admin') {
         if (_selectedBranch != null) query += '&branch=$_selectedBranch';
      } else {
         // Pass user's branch as context logic usually expects it
         query += '&branch=${user.branch}';
         // If they selected a filter branch that is DIFFERENT from their own, they get empty result (correct).
         // If they selected SAME, it works.
         // If they selected NULL (All), they see their branch (correct). 
      }

      if (_selectedStatus != null) query += '&status=$_selectedStatus';
      
      final response = await ApiService.get('/tickets?$query');
      
      if (mounted) {
        setState(() {
          _tickets = (response as List).map((t) => Ticket.fromJson(t)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching report tickets: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open': return Colors.blue;
      case 'In Progress': return Colors.orange;
      case 'Resolved': return Colors.green;
      case 'Closed': return Colors.grey;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // drawer: const SideMenu(), // Removed to show Back button
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    value: _selectedStatus,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Statuses')),
                      ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedStatus = val);
                      _fetchTickets();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Branch',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                    value: _selectedBranch,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Branches')),
                      ..._branches.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedBranch = val);
                      _fetchTickets();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Results: ${_tickets.length} tickets', 
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchTickets,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No tickets found', style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tickets.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                ticket.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(ticket.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: _getStatusColor(ticket.status)),
                                        ),
                                        child: Text(
                                          ticket.status,
                                          style: TextStyle(
                                            color: _getStatusColor(ticket.status), 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                      Text(
                                        ticket.branch,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ticket.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
