import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../tickets/create_ticket_screen.dart';
import '../tickets/ticket_detail_screen.dart';
import '../auth/login_screen.dart';

import '../../widgets/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
    ConfiguredFuture();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService.get('/tickets/stats');
      if (mounted) {
        setState(() {
          _stats = Map<String, int>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  void ConfiguredFuture() {
    // Delay slightly to ensure context is available and AuthProvider is ready
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.user;
      if (user != null) {
        Provider.of<TicketProvider>(context, listen: false)
            .fetchTickets(role: user.role, userId: user.id, branch: user.branch);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.username ?? "User"}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${user?.role} - ${user?.branch}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                _buildStatCard('Pending', _stats['pending']?.toString() ?? '0', Colors.orange),
                const SizedBox(width: 8),
                _buildStatCard('Created Today', _stats['createdToday']?.toString() ?? '0', Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('Closed Today', _stats['closedToday']?.toString() ?? '0', Colors.green),
              ],
            ),
          ),

          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.tickets.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => ConfiguredFuture(),
                    child: ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('No tickets found', style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ConfiguredFuture(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = provider.tickets[index];
                          final assigneeName = ticket.assignedTo != null ? ticket.assignedTo!.username : 'Unassigned';
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketDetailScreen(ticket: ticket),
                                  ),
                                ).then((_) => ConfiguredFuture());
                              },
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                ticket.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _buildTag(ticket.status, _getStatusColor(ticket.status)),
                                      _buildTag(ticket.priority, _getPriorityColor(ticket.priority)),
                                      // Show Assignee
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person_outline, size: 12, color: Colors.grey[700]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Assigned: $assigneeName',
                                              style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                   Text(ticket.category, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
          ).then((_) {
             // Refresh list after returning
             ConfiguredFuture();
          });
        },
        label: const Text('New Ticket'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.blue;
    }
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
