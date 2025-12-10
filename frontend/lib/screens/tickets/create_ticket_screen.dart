import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api_service.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedPriority = 'Medium';
  String? _selectedBranch; // For Admin/Super
  String? _selectedAssignee;

  List<dynamic> _categories = [];
  List<dynamic> _branches = [];
  List<dynamic> _users = [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final categories = await ApiService.get('/master/categories');
      final branches = await ApiService.get('/master/branches');
      final users = await ApiService.get('/master/users'); // Fetch users
      if (mounted) {
        setState(() {
          _categories = categories;
          _branches = branches;
          _users = users;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  void _createTicket() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select Category')));
        return;
      }

      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final branch = user!.role == 'Staff' ? user.branch : _selectedBranch;

      if (branch == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select Branch')));
         return;
      }

      try {
        await Provider.of<TicketProvider>(context, listen: false).createTicket(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory!,
          priority: _selectedPriority!,
          branch: branch,
          createdBy: user!.id,
          assignedTo: _selectedAssignee, // Pass assigned user ID
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isStaff = user?.role == 'Staff';

    // Filter users list to exclude current user maybe? Or show all. 
    // Showing all is fine for now.

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Ticket')),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem(value: c['name'], child: Text(c['name']));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: _selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['Low', 'Medium', 'High'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _selectedPriority = val),
                    ),
                    const SizedBox(height: 16),
                    if (!isStaff) ...[
                       DropdownButtonFormField(
                        value: _selectedBranch,
                        decoration: const InputDecoration(labelText: 'Branch'),
                        items: _branches.map<DropdownMenuItem<String>>((b) {
                          return DropdownMenuItem(value: b['name'], child: Text(b['name']));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedBranch = val),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Assign To Dropdown
                     DropdownButtonFormField(
                      value: _selectedAssignee,
                      decoration: const InputDecoration(labelText: 'Assign To (Optional)'),
                      items: _users.map<DropdownMenuItem<String>>((u) {
                        return DropdownMenuItem(value: u['_id'], child: Text('${u['username']} (${u['role']})'));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAssignee = val),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<TicketProvider>(
                        builder: (context, ticketProvider, _) {
                          return ElevatedButton(
                            onPressed: ticketProvider.isLoading ? null : _createTicket,
                            child: ticketProvider.isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('CREATE TICKET'),
                          );
                        },
                      ),
                    ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
